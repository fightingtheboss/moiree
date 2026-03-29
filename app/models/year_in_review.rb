# frozen_string_literal: true

class YearInReview < ApplicationRecord
  include Summarizable

  has_many :year_in_review_top_selections, -> { order(:position) }, dependent: :destroy, inverse_of: :year_in_review
  has_many :top_selections, through: :year_in_review_top_selections, source: :selection

  belongs_to :bombe_moiree_selection, class_name: "Selection", optional: true
  belongs_to :most_divisive_selection, class_name: "Selection", optional: true

  validates :year,
    presence: true,
    uniqueness: true,
    numericality: { only_integer: true, greater_than: 2023 }

  scope :chronological, -> { order(year: :desc) }

  class << self
    def for(year)
      record = find_or_create_by!(year: year)
      record.generate! if record.stale?
      record
    end

    def current
      self.for(Date.current.year)
    end
  end

  def editions
    Edition.within(year).includes(:festival).order(start_date: :desc)
  end

  def stale?
    generated_at.nil? || editions.any? { |e| e.updated_at > generated_at }
  end

  def generate!
    edition_ids = Edition.within(year).pluck(:id)

    if edition_ids.empty?
      update!(
        editions_count: 0,
        critics_count: 0,
        films_count: 0,
        ratings_count: 0,
        five_star_ratings_count: 0,
        zero_star_ratings_count: 0,
        bombe_moiree_selection: nil,
        most_divisive_selection: nil,
        generated_at: Time.current,
      )
      year_in_review_top_selections.destroy_all
      return self
    end

    # Top-level stats
    self.editions_count = edition_ids.size
    self.critics_count = Attendance.where(edition_id: edition_ids).distinct.count(:critic_id)
    self.films_count = summary_selections.distinct.count(:film_id)
    self.ratings_count = summary_ratings.count
    self.five_star_ratings_count = five_star_ratings.count
    self.zero_star_ratings_count = zero_star_ratings.count

    self.bombe_moiree_selection = bombe_moiree
    self.most_divisive_selection = most_divisive

    self.generated_at = Time.current

    save!

    # Top films of the year
    assign_top_selections!(edition_ids)

    self
  end

  # Returns YearInReviewTopSelection join records with eager-loaded associations.
  # Each record carries combined_average_rating and combined_ratings_count
  # aggregated across all editions in the year.
  def top_selections_with_includes
    year_in_review_top_selections
      .includes(selection: [:film, { ratings: :critic }])
      .order(:position)
  end

  # Use cached associations for histograms (populated by generate!)
  def bombe_moiree_histogram
    build_histogram(bombe_moiree_selection)
  end

  def most_divisive_histogram
    build_histogram(most_divisive_selection)
  end

  def summary_critics_count
    Attendance.where(edition_id: Edition.within(year).select(:id)).distinct.count(:critic_id)
  end

  # Scope summary queries to all editions in this year
  def summary_selections
    Selection.where(edition_id: Edition.within(year).select(:id))
  end

  private

  def assign_top_selections!(edition_ids)
    # Step 1: Per-edition qualification.
    # A film qualifies if it meets the threshold for the edition where it was screened,
    # preventing large festivals from unfairly raising the bar for smaller editions.
    qualifying_film_ids = []
    Edition.where(id: edition_ids).each do |edition|
      threshold = edition.min_ratings_for_summary
      film_ids = Rating
        .joins(:selection)
        .where(selections: { edition_id: edition.id })
        .group("selections.film_id")
        .having("COUNT(ratings.id) >= ?", threshold)
        .pluck("selections.film_id")
      qualifying_film_ids |= film_ids
    end

    year_in_review_top_selections.destroy_all
    return if qualifying_film_ids.empty?

    # Step 2: Compute combined stats across all editions for qualifying films.
    film_aggregates = Rating
      .joins(selection: :film)
      .where(selections: { edition_id: edition_ids, film_id: qualifying_film_ids })
      .where(films: { year: year })
      .group("films.id")
      .pluck(Arel.sql("films.id, AVG(ratings.score), COUNT(ratings.id)"))

    return if film_aggregates.empty?

    # Step 3: Compute global mean C across all qualifying ratings in the year.
    total_ratings = film_aggregates.sum { |_, _, count| count }
    global_mean = film_aggregates.sum { |_, avg, count| avg * count } / total_ratings.to_f

    # Step 4: Bayesian weighted ranking.
    # weighted_score = (v / (v + m)) * R + (m / (v + m)) * C
    # R = raw average, v = rating count, m = year-wide min_ratings_for_summary (tuning constant), C = global mean.
    # Films with fewer ratings are pulled closer to the mean, reducing noise from small samples.
    m = min_ratings_for_summary.to_f
    scored_films = film_aggregates.map do |film_id, avg_rating, ratings_count|
      v = ratings_count.to_f
      weighted = (v / (v + m)) * avg_rating + (m / (v + m)) * global_mean
      [film_id, avg_rating, ratings_count, weighted]
    end

    # Step 5: Rank by weighted score descending, take top 5.
    top_films = scored_films.sort_by { |_, _, _, weighted| -weighted }.first(5)

    # For each top film, pick a representative selection (the one with the most ratings)
    # to use for featured_rating, poster, etc.
    top_films.each_with_index do |(film_id, avg_rating, ratings_count, weighted_score), index|
      representative = Selection
        .joins(:ratings)
        .where(edition_id: edition_ids, film_id: film_id)
        .group("selections.id")
        .order("COUNT(ratings.id) DESC")
        .first

      year_in_review_top_selections.create!(
        selection: representative,
        position: index + 1,
        combined_average_rating: avg_rating,
        combined_ratings_count: ratings_count,
        weighted_score: weighted_score,
      )
    end
  end
end
