# frozen_string_literal: true

class Admin
  class Podcasts::EpisodesController < ApplicationController
    before_action :podcast, only: [:new, :create, :edit, :update, :destroy]
    before_action :episode, only: [:edit, :update, :destroy]

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

    private

    def episode_params
      params.require(:podcast_episode).permit(:title, :description, :url, :embed, :target_collection_id)
    end

    def podcast
      @podcast = Podcast.friendly.find(params[:podcast_id])
    end

    def episode
      @episode = @podcast.episodes.friendly.find(params[:id])
    end
  end
end
