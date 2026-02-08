# frozen_string_literal: true

class YearsController < ApplicationController
  include TopFilms

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
end
