# frozen_string_literal: true

class YearsController < ApplicationController
  def show
    @year = params[:id].to_i
    @year_in_review = YearInReview.find_or_create_by!(year: @year)
    @year_in_review.generate! if @year_in_review.stale?

    if stale?(@year_in_review)
      @top_films = @year_in_review.top_selections_with_includes
      @editions = @year_in_review.editions
    end
  end
end
