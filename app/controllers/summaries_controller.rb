# frozen_string_literal: true

class SummariesController < ApplicationController
  def show
    @edition = Edition.friendly.find(params[:edition_id])

    if stale?(@edition)
      @edition = Edition.includes(
        :categories,
        :critics,
        :selections,
        ratings: :critic,
      ).friendly.find(params[:edition_id])

      @selections_for_standalone = @edition.selections.includes(:category, :film, ratings: :critic)
        .where(category: { standalone: true })
        .group("selections.id")
        .having("COUNT(ratings.id) >= ?", @edition.min_ratings_for_summary)
        .order(average_rating: :desc)
        .group_by(&:category)
        .sort_by { |category, _| category.position }

      @selections_for_others = @edition.selections.includes(:category, :film, ratings: :critic)
        .where(category: { standalone: false })
        .group("selections.id")
        .having("COUNT(ratings.id) >= ?", @edition.min_ratings_for_summary)
        .order(average_rating: :desc)

      @bombe_moiree = @edition.bombe_moiree
      @bombe_moiree_histogram = @edition.bombe_moiree_histogram

      @five_star_ratings = @edition.five_star_ratings
      @zero_star_ratings = @edition.zero_star_ratings

      @most_divisive = @edition.most_divisive
      @most_divisive_histogram = @edition.most_divisive_histogram
    end
  end
end
