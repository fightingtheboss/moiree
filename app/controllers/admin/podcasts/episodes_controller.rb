# frozen_string_literal: true

class Admin
  class Podcasts::EpisodesController < AdminController
    before_action :podcast, only: [:new, :create, :edit, :update, :destroy]
    before_action :episode, only: [:edit, :update, :destroy]
    before_action :ensure_webhook_source, only: [:webhook]

    # Webhooks come from an external provider (Transistor.fm). They can't include
    # the application's CSRF token, so we must skip the verification for this
    # endpoint only.
    skip_before_action :verify_authenticity_token, only: [:webhook]

    allow_unauthenticated_access(only: :webhook)

    def new
      authorize(@podcast, :create?)

      @episode = @podcast.episodes.new
    end

    def create
      authorize(@podcast, :create?)
      @episode = @podcast.episodes.new(episode_params)

      if @episode.save
        respond_to do |format|
          format.html { redirect_to(admin_podcast_path(@podcast), notice: "Episode created") }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { render(:new) }
          format.turbo_stream do
            flash.now[:alert] = @episode.errors.full_messages.to_sentence
            render(
              turbo_stream: [
                turbo_stream.prepend("flash", partial: "layouts/flash"),
                turbo_stream.update(
                  "modal",
                  partial: "admin/podcasts/episodes/form",
                  locals: { podcast_episode: @episode, podcast: @podcast },
                ),
              ],
              status: :unprocessable_entity,
            )
          end
        end
      end
    end

    def edit
      authorize(@episode)
    end

    def update
      authorize(@episode)

      if @episode.update(episode_params)
        respond_to do |format|
          format.html { redirect_to(admin_podcasts_path, notice: "#{@episode.title} updated") }
          format.turbo_stream do
            flash.now[:notice] = "#{@episode.title} updated"
            render(turbo_stream: [
              turbo_stream.prepend("flash", partial: "layouts/flash"),
              turbo_stream.update(
                helpers.dom_id(@episode),
                partial: "admin/podcasts/episodes/episode",
                locals: { episode: @episode },
              ),
            ])
          end
        end
      else
        render(:edit)
      end
    end

    def destroy
      authorize(@episode)

      if @episode.destroy
        redirect_to(admin_podcast_path(@podcast), notice: "Episode deleted")
      else
        redirect_to(admin_podcast_path(@podcast), alert: "Failed to delete episode")
      end
    end

    def webhook
      event_name, episode_params = transistor_webhook_params
      episode_attributes = episode_params[:attributes]

      head(:bad_request) and return unless event_name == "episode_published"
      head(:ok) and return if episode_attributes[:status] == "draft"

      @podcast = Podcast.friendly.find(params[:podcast_id])

      @episode = @podcast.episodes.build(
        provider_id: episode_params[:id],
        title: episode_attributes[:title],
        description: episode_attributes[:formatted_description],
        url: episode_attributes[:share_url],
        embed: episode_attributes[:embed_html],
        summary: episode_attributes[:formatted_summary],
        published_at: episode_attributes[:published_at],
        slug: episode_attributes[:slug],
        duration: episode_attributes[:duration],
      )

      if @episode.save
        head(:ok)
      else
        Rails.logger.error("Failed to create episode from webhook: #{@episode.errors.full_messages.join(", ")}")
        Bugsnag.notify("Failed to create episode from webhook: #{@episode.errors.full_messages.join(", ")}")

        head(:unprocessable_entity)
      end
    end

    private

    def episode_params
      params.expect(
        episode: [
          :title,
          :summary,
          :description,
          :url,
          :embed,
          :published_at,
          :edition_id,
        ],
      )
    end

    def podcast
      @podcast = Podcast.friendly.find(params[:podcast_id])
    end

    def episode
      @episode = @podcast.episodes.friendly.find(params[:id])
    end

    def ensure_webhook_source
      unless request.user_agent == "Transistor.fm/1.0"
        head(:forbidden)
      end
    end

    def transistor_webhook_params
      params.expect(
        :event_name,
        data: [
          :id,
          attributes: [
            :title,
            :formatted_summary,
            :formatted_description,
            :share_url,
            :embed_html,
            :slug,
            :published_at,
            :duration,
            :status,
          ],
        ],
      )
    end
  end
end
