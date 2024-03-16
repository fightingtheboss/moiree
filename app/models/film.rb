# frozen_string_literal: true

class Film < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  has_many :selections, dependent: :destroy
  has_many :editions, through: :selections
  has_many :ratings, through: :selections

  def cache_overall_average_rating
    update(overall_average_rating: ratings.average(:score).to_f)
  end
end
