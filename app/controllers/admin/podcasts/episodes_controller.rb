# frozen_string_literal: true

class Admin
  class Podcasts::EpisodesController < ApplicationController
    before_action :podcast, only: [:new, :create, :edit, :update, :destroy]
    before_action :episode, only: [:edit, :update, :destroy]
    before_action :ensure_webhook_source, only: [:webhook]

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
        render(:new)
      end
    end

    def edit
      authorize(@episode)
    end

    def update
      authorize(@episode)

      if @episode.update(episode_params)
        redirect_to(admin_podcast_path(@podcast), notice: "Episode updated")
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

      @podcast = Podcast.first
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
      params.expect(podcast_episode: [:title, :description, :url, :embed, :target_collection_id])
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
