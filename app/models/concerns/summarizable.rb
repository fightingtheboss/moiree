# frozen_string_literal: true

module Summarizable
  extend ActiveSupport::Concern

  MIN_RATINGS_FLOOR = 4
  CRITIC_POOL_DIVISOR = 3.0

  # Compute the minimum ratings threshold for a given critic pool size.
  # Available as both Summarizable.threshold_for(...) and as a class method
  # on any model that includes Summarizable.
  def self.threshold_for(critic_count)
    [(critic_count / CRITIC_POOL_DIVISOR).ceil, MIN_RATINGS_FLOOR].max
  end

  # Includers must implement this to define the critic pool size.
  # For Edition, this is the number of attending critics.
  # For YearInReview, this is the distinct critics across all editions in the year.
  def summary_critics_count
    raise NotImplementedError, "#{self.class} must implement #summary_critics_count"
  end

  # Dynamic threshold: 1/3 of the critic pool, with a floor of MIN_RATINGS_FLOOR.
  def min_ratings_for_summary
    Summarizable.threshold_for(summary_critics_count)
  end

  # Override in models without a direct `selections` association.
  # Must return an ActiveRecord::Relation of Selection.
  def summary_selections
    selections
  end

  # Bombe Moirée — lowest rated selection with enough ratings
  def bombe_moiree
    summary_selections
      .joins(:ratings)
      .group("selections.id")
      .having("COUNT(ratings.id) >= ?", min_ratings_for_summary)
      .order(average_rating: :asc)
      .first
  end

  # Most divisive — highest standard deviation among selections with enough ratings
  def most_divisive
    summary_selections
      .includes(:ratings)
      .where.not(ratings: { id: nil })
      .to_a
      .select { |s| s.ratings.size >= min_ratings_for_summary }
      .max_by(&:ratings_standard_deviation)
  end

  # Builds a score histogram (0.0–5.0 in 0.5 increments) for a given selection
  def build_histogram(selection)
    return {} unless selection

    histogram = selection.ratings.group_by(&:score).transform_values(&:size)
    (0..5).step(0.5).each { |score| histogram[score.to_d] ||= 0 }
    histogram.sort.to_h
  end

  def bombe_moiree_histogram
    build_histogram(bombe_moiree)
  end

  def most_divisive_histogram
    build_histogram(most_divisive)
  end

  def five_star_ratings
    summary_ratings
      .where(score: 5.0)
      .joins(:critic, :film)
      .includes(:critic, :film)
      .order("films.title")
  end

  def zero_star_ratings
    summary_ratings
      .where(score: 0.0)
      .joins(:critic, :film)
      .includes(:critic, :film)
      .order("films.title")
  end

  private

  def summary_ratings
    Rating.joins(:selection).merge(summary_selections)
  end
end
