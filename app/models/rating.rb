# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :critic
  belongs_to :selection, touch: true

  has_one :edition, through: :selection
  has_one :film, through: :selection

  validates :score, presence: true
  validates :score,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 },
    format: { with: /\A\d(\.\d)?\z/ }
  validates :selection_id, uniqueness: {
    scope: :critic_id,
    message: ->(object, _) { "#{object.critic.name} has already rated #{object.film.title}" },
  }

  attr_accessor :skip_cache_average_ratings_callback

  after_commit :cache_average_ratings, unless: :skip_cache_average_ratings_callback

  private

  def cache_average_ratings
    CacheAverageRatingJob.perform_later(selection)
  end
end
