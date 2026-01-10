# frozen_string_literal: true

class Selection < ApplicationRecord
  belongs_to :edition, inverse_of: :selections, touch: true
  belongs_to :film, inverse_of: :selections
  belongs_to :category, inverse_of: :selections

  has_many :ratings, dependent: :destroy
  has_many :critics, through: :ratings

  validates :edition_id, uniqueness: { scope: :film_id }

  accepts_nested_attributes_for :film

  after_touch :touch_edition

  def cache_average_rating
    update(average_rating: ratings.where(critic: edition.critics).average(:score).to_f)
  end

  def ratings_standard_deviation
    number_of_ratings = ratings.size

    return 0 if number_of_ratings < 4

    variance = ratings.map do |r|
      (r.score - average_rating)**2
    end.sum / (number_of_ratings - 1)

    Math.sqrt(variance)
  end

  def touch_edition
    edition.touch
  end
end
