# frozen_string_literal: true

class DailySummaryTweetJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Edition.current.each do |edition|
      local_time = Time.now.in_time_zone(edition.timezone)
      next unless local_time.hour == 23 && local_time.min >= 45

      summary = DailySummaryTweet.new(edition)
      next if summary.premiere_selections.none?

      summary.post!
    end
  end
end
