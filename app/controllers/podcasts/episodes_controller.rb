# frozen_string_literal: true

class Podcasts::EpisodesController < ApplicationController
  def show
    @podcast = Podcast.friendly.find(params[:podcast_id])
    @episode = @podcast.episodes.find_by(slug: params[:id])
  end
end
