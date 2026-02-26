# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @year = Date.current.year
    setup_homepage_data
  end

  private

  def setup_homepage_data
    # Ongoing festivals (currently happening)
    @current = Edition.current

    # Highly reviewed films of the year (3-5 with best average ratings and impressions)
    @top_films = YearInReview.current.top_selections_with_includes

    # Most recent completed festival from the year
    @recent_festival = Edition.past.where("CAST(strftime('%Y', end_date) AS INTEGER) = ?", @year).first

    # Top rated films from the recent festival (only needed when no current festivals)
    if @current.empty? && @recent_festival
      @recent_top_selections = @recent_festival.selections
        .joins(:ratings)
        .includes(:film)
        .select("selections.*, COUNT(ratings.id) AS ratings_total")
        .group("selections.id")
        .having("COUNT(ratings.id) >= 4")
        .order(average_rating: :desc)
        .limit(4)
    end

    # Latest podcast episode
    @latest_episode = Podcast.platform.first.episodes.order(published_at: :desc).first

    # Upcoming festivals
    @upcoming = Edition.upcoming

    # Past festivals from the year (for archive preview)
    @past = Edition.past
      .where("CAST(strftime('%Y', start_date) AS INTEGER) = ?", @year)
      .limit(6)
  end
end
