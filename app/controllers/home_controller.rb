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
    @top_films = top_films_of_year(@year)

    # Most recent completed festival from the year
    @recent_festival = Edition.past.where("CAST(strftime('%Y', end_date) AS INTEGER) = ?", @year).first

    # Latest podcast episode
    @latest_episode = Episode.order(published_at: :desc).first

    # Upcoming festivals
    @upcoming = Edition.upcoming

    # Past festivals from the year (for archive preview)
    @past = Edition.past
      .where("CAST(strftime('%Y', start_date) AS INTEGER) = ?", @year)
      .limit(6)
  end

  def top_films_of_year(year)
    # Films with highest average ratings that have impressions, from editions in the given year
    edition_ids = Edition.where("CAST(strftime('%Y', start_date) AS INTEGER) = ?", year).pluck(:id)

    return [] if edition_ids.empty?

    Selection.joins(:ratings, :film)
      .where(edition_id: edition_ids)
      .where.not(ratings: { impression: [nil, ""] })
      .group("selections.id")
      .having("COUNT(ratings.id) >= 2")
      .order("AVG(ratings.score) DESC")
      .limit(5)
      .includes(:film, ratings: :critic)
  end
end
