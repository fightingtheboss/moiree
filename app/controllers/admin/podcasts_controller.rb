# frozen_string_literal: true

class Admin::PodcastsController < AdminController
  def index
  end

  def show
  end

  def new
    @podcast = Podcast.new
  end

  def create
    @podcast = Podcast.new(podcast_params)

    if @podcast.save
      redirect_to(admin_podcasts_path, notice: "Podcast created")
    else
      render(:new)
    end
  end

  private

  def podcast_params
    params.require(:podcast).permit(:title, :description, :url, :published_at)
  end
end
