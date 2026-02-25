# frozen_string_literal: true

class YearInReview < ApplicationRecord
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
    self.films_count = Selection.where(edition_id: edition_ids).distinct.count(:film_id)
    self.ratings_count = Rating.joins(:selection).where(selections: { edition_id: edition_ids }).count
    self.five_star_ratings_count = Rating.joins(:selection).where(selections: { edition_id: edition_ids }, score: 5.0).count
    self.zero_star_ratings_count = Rating.joins(:selection).where(selections: { edition_id: edition_ids }, score: 0.0).count

    # Bombe Moirée — lowest rated film across all editions (≥4 ratings)
    self.bombe_moiree_selection = Selection
      .joins(:ratings)
      .where(edition_id: edition_ids)
      .group("selections.id")
      .having("COUNT(ratings.id) >= 4")
      .order(average_rating: :asc)
      .first

    # Most divisive — highest standard deviation (requires loading ratings)
    divisive_candidates = Selection
      .includes(:ratings)
      .where(edition_id: edition_ids)
      .where.not(ratings: { id: nil })
      .to_a
      .select { |s| s.ratings.size >= 4 }

    self.most_divisive_selection = divisive_candidates
      .max_by(&:ratings_standard_deviation)

    self.generated_at = Time.current

    save!

    # Top films of the year
    assign_top_selections!(edition_ids)

    self
  end

  # Eager-load top selections with their associations for display
  def top_selections_with_includes
    top_selections.includes(:film, ratings: :critic)
  end

  # Histogram data for the bombe moirée selection
  def bombe_moiree_histogram
    return {} unless bombe_moiree_selection

    build_histogram(bombe_moiree_selection)
  end

  # Histogram data for the most divisive selection
  def most_divisive_histogram
    return {} unless most_divisive_selection

    build_histogram(most_divisive_selection)
  end

  def five_star_ratings
    edition_ids = Edition.within(year).pluck(:id)
    Rating.joins(:selection, :critic, :film)
      .where(selections: { edition_id: edition_ids }, score: 5.0)
      .includes(:critic, :film)
      .order("films.title")
  end

  def zero_star_ratings
    edition_ids = Edition.within(year).pluck(:id)
    Rating.joins(:selection, :critic, :film)
      .where(selections: { edition_id: edition_ids }, score: 0.0)
      .includes(:critic, :film)
      .order("films.title")
  end

  private

  def assign_top_selections!(edition_ids)
    # Best selection per film (highest average_rating), requiring ≥2 ratings
    best_selection_ids = Selection.joins(:ratings)
      .where(edition_id: edition_ids)
      .group("selections.id")
      .having("COUNT(ratings.id) >= 2")
      .select("selections.id, selections.film_id, selections.average_rating")
      .then do |selections|
        selections.group_by(&:film_id).map { |_, sels| sels.max_by(&:average_rating).id }
      end

    top = Selection.where(id: best_selection_ids)
      .order(average_rating: :desc)
      .limit(5)

    year_in_review_top_selections.destroy_all
    top.each_with_index do |selection, index|
      year_in_review_top_selections.create!(selection: selection, position: index + 1)
    end
  end

  def build_histogram(selection)
    histogram = selection.ratings.group_by(&:score).transform_values(&:size)
    (0..5).step(0.5).each do |score|
      histogram[score.to_d] ||= 0
    end
    histogram.sort.to_h
  end
end
