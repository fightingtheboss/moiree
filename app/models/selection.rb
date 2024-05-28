# frozen_string_literal: true

class Selection < ApplicationRecord
  belongs_to :edition, inverse_of: :selections
  belongs_to :film, inverse_of: :selections
  belongs_to :category, inverse_of: :selections

  has_many :ratings, dependent: :destroy
  has_many :critics, through: :ratings

  validates :edition_id, uniqueness: { scope: :film_id }

  accepts_nested_attributes_for :film

  def cache_average_rating
    update(average_rating: ratings.where(critic: edition.critics).average(:score).to_f)
  end

  def ratings_standard_deviation
    number_of_ratings = ratings.size

    return 0 if number_of_ratings < 2

    variance = ratings.map { |r|
      (r.score - average_rating)**2
    }.sum / (number_of_ratings - 1)

    Math.sqrt(variance)
  end
end
