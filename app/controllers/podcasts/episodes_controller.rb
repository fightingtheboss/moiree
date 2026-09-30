# frozen_string_literal: true

class Podcasts::EpisodesController < ApplicationController
  def show
    @podcast = Podcast.friendly.find(params[:podcast_id])
    @episode = @podcast.episodes.friendly.find(params[:id])
  end
end
