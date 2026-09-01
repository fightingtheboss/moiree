# frozen_string_literal: true

class Selection < ApplicationRecord
  belongs_to :edition, inverse_of: :selections, touch: true
  belongs_to :film, inverse_of: :selections
  belongs_to :category, inverse_of: :selections

  has_many :ratings, dependent: :destroy
  has_many :native_ratings, -> { native }, class_name: "Rating"
  has_many :critics, through: :ratings

  validates :edition_id, uniqueness: { scope: :film_id }

  accepts_nested_attributes_for :film

  after_commit :enqueue_inherit_ratings, on: :create

  def featured_rating
    ratings.counting_towards_aggregates.where.not(impression: [nil, ""]).order(score: :desc).first
  end

  def cache_average_rating
    update(average_rating: native_ratings.where(critic: edition.critics).counting_towards_aggregates.average(:score).to_f)
  end

  def ratings_standard_deviation
    rated = native_ratings.reject(&:walked_out?)
    return 0 if rated.size < 4

    mean = rated.sum(&:score) / rated.size.to_f
    variance = rated.sum { |r| (r.score - mean)**2 } / (rated.size - 1)
    Math.sqrt(variance)
  end

  private

  def enqueue_inherit_ratings
    InheritRatingsForSelectionJob.perform_later(self)
  end
end
