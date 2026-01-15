# frozen_string_literal: true

class YearsController < ApplicationController
  def show
    @year = params[:id].to_i
    setup_year_data
  end

  private

  def setup_year_data
    # Highly reviewed films of the year (3-5 with best average ratings and impressions)
    @top_films = top_films_of_year(@year)

    # Most recent completed festival from the year
    @recent_festival = Edition.past.ending_in(@year).first

    # Past festivals from the year
    @past = Edition.past.within(@year).limit(6)
  end

  def top_films_of_year(year)
    edition_ids = Edition.within(year).pluck(:id)

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
