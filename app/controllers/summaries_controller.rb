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
        .having("COUNT(ratings.id) >= 4")
        .order(average_rating: :desc)
        .group_by(&:category)

      @selections_for_others = @edition.selections.includes(:category, :film, ratings: :critic)
        .where(category: { standalone: false })
        .group("selections.id")
        .having("COUNT(ratings.id) >= 4")
        .order(average_rating: :desc)

      @bombe_moiree = @edition.selections
        .joins(:ratings)
        .group("selections.id")
        .having("COUNT(ratings.id) >= 4")
        .order(average_rating: :asc)
        .first

      if @bombe_moiree
        @bombe_moiree_histogram = @bombe_moiree.ratings.group_by(&:score).transform_values(&:size)
        (0..5).step(0.5).each do |score|
          @bombe_moiree_histogram[score.to_d] ||= 0
        end

        @bombe_moiree_histogram = @bombe_moiree_histogram.sort.to_h
      end

      @five_star_ratings = @edition.ratings.includes(:critic, :film).where({ score: 5.0 }).order("films.title")
      @zero_star_ratings = @edition.ratings.includes(:critic, :film).where({ score: 0.0 }).order("films.title")

      @most_divisive = @edition.selections
        .includes(:ratings)
        .where.not(ratings: { id: nil })
        .sort_by(&:ratings_standard_deviation)
        .reverse
        .first

      if @most_divisive
        @most_divisive_histogram = @most_divisive.ratings.all.group_by(&:score).transform_values(&:size)
        (0..5).step(0.5).each do |score|
          @most_divisive_histogram[score.to_d] ||= 0
        end

        @most_divisive_histogram = @most_divisive_histogram.sort.to_h
      end
    end
  end
end
