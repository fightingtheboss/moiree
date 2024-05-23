# frozen_string_literal: true

class CacheAverageRatingJob < ApplicationJob
  queue_as :default

  def perform(selection)
    selection.cache_average_rating
    selection.film.cache_overall_average_rating
  end
end
