# frozen_string_literal: true

class PodcastsController < ApplicationController
  def index
    @podcasts = Podcast.order(created_at: :desc)
  end

  def show
    @podcast = Podcast.friendly.find(params[:id])
    @episodes = @podcast.episodes.order(published_at: :desc).to_a
    @latest_episode = @episodes.shift
  end
end
