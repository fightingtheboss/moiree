# frozen_string_literal: true

class CacheEditionAverageRatingsJob < ApplicationJob
  queue_as :default

  # Enqueued when an attendance is destroyed, which also happens when its edition is destroyed
  discard_on ActiveJob::DeserializationError

  def perform(edition)
    edition.cache_average_ratings
  end
end
