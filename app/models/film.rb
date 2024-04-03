# frozen_string_literal: true

class Film < ApplicationRecord
  include Importable

  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  has_many :selections, dependent: :destroy
  has_many :editions, through: :selections
  has_many :ratings, through: :selections

  validates :title, :director, :country, :year, presence: true

  accepts_nested_attributes_for :categorizations

  def cache_overall_average_rating
    update(overall_average_rating: ratings.average(:score).to_f)
  end

  def directors
    director.split(",").map(&:strip)
  end

  def countries
    country.split(",").map(&:strip).map { |c| Country[c].common_name }
  end

  def category(edition)
    categories.find_by(edition: edition)
  end
end
