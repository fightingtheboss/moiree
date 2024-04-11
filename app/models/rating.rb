# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :critic
  belongs_to :selection

  has_one :film, through: :selection

  validates :score, presence: true
  validates :score,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 },
    format: { with: /\A\d(\.\d)?\z/ }
  validates :selection_id, uniqueness: { scope: :critic_id }

  after_create :cache_overall_average_rating_on_film
  after_destroy :cache_overall_average_rating_on_film

  private

  # This should be a background job in the long run.
  # I don't even think it's wise to have side-effects in callbacks like this (but it's fine for now)
  def cache_overall_average_rating_on_film
    film.cache_overall_average_rating
  end
end
