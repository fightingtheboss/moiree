# frozen_string_literal: true

class DailySummaryTweetJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if Edition.current.any?
      Edition.current.each do |edition|
        summary = DailySummaryTweet.new(edition)

        next if summary.ratings.none?

        summary.post!
      end
    end
  end
end
