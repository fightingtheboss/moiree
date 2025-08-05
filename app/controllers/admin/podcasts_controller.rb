# frozen_string_literal: true

class Admin
  class PodcastsController < AdminController
    def index
      @podcasts = Podcast.all
    end

    def show
      @podcast = Podcast.friendly.find(params[:id])
    end

    def new
      @podcast = Podcast.new
    end

    def create
      @podcast = Podcast.new(podcast_params)
      @podcast.user = current_user

      authorize(@podcast)

      if @podcast.save
        respond_to do |format|
          format.html { redirect_to(admin_podcasts_path, notice: "Podcast created") }
          format.turbo_stream
        end
      else
        render(:new)
      end
    end

    def edit
      @podcast = Podcast.friendly.find(params[:id])
      authorize(@podcast)
    end

    def update
      @podcast = Podcast.friendly.find(params[:id])

      authorize(@podcast)

      if @podcast.update(podcast_params)
        respond_to do |format|
          format.html do
            redirect_to(
              admin_podcast_path(@podcast),
              notice: "Podcast updated",
            )
          end

          format.turbo_stream do
            flash.now[:notice] = "#{@podcast.title} updated"
            render(turbo_stream: [
              turbo_stream.prepend("flash", partial: "layouts/flash"),
              turbo_stream.replace(
                helpers.dom_id(@podcast),
                partial: "admin/podcasts/podcast",
                locals: { podcast: @podcast },
              ),
            ])
          end
        end
      else
        render(:edit)
      end
    end

    private

    def podcast_params
      params.require(:podcast).permit(:title, :description, :url, :platform)
    end
  end
end
