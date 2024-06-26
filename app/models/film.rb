# frozen_string_literal: true

class Film < ApplicationRecord
  include Importable, Searchable
  include FriendlyId

  has_many :selections, dependent: :destroy, inverse_of: :film
  has_many :editions, through: :selections
  has_many :ratings, through: :selections do
    def for(edition)
      where(selections: { edition_id: edition.id })
    end

    def by(critic)
      where(ratings: { critic: critic })
    end
  end

  validates :title, :director, :country, :year, presence: true

  friendly_id :slug_candidates, use: :slugged

  def cache_overall_average_rating
    update(overall_average_rating: ratings.average(:score).to_f)
  end

  def directors
    director.split(",").map(&:strip)
  end

  def countries
    country.split(",").map(&:strip).map { |c| Country[c].common_name }
  end

  private

  def slug_candidates
    [
      :title,
      [:title, :year],
      [:title, :year, :country],
    ]
  end
end
