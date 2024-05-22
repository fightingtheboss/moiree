# frozen_string_literal: true

class DailySummaryTweetJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if Edition.current.any?
      x_client = X::Client.new(**Rails.application.credentials.x)

      Edition.current.each do |edition|
        # Grab the ratings for the current edition in the last 24 hours
        ratings = edition.ratings.includes(:selection, :film).where("ratings.created_at > ?", 1.day.ago)

        next if ratings.none?

        selections = ratings.map(&:selection).uniq
        films = ratings.map(&:film).uniq

        tweet = <<~TWEET
          ⭐️ #{edition.code} Day #{edition.current_day} Ratings ⭐️

          There were #{ratings.count} ratings from our critics across #{films.count} films. Here are the new averages for rated films:

          #{selections.map { |selection| "• #{selection.film.title} -> #{selection.average_rating}" }.join("\n")}

          Visit #{edition_url(edition)} for detailed ratings
        TWEET

        x_client.post("tweets", { text: tweet }.to_json)

        # DailySummaryTweet.new(edition).tweet
      end
    end
  end
end
