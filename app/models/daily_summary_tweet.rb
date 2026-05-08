# frozen_string_literal: true

class DailySummaryTweet
  include ActionView::Helpers::TextHelper, ActiveSupport::NumberHelper

  MIN_RATINGS = 4

  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def premiere_selections
    @premiere_selections ||= edition.selections
      .joins(:ratings)
      .group("selections.id")
      .having("MIN(ratings.created_at) > ?", 1.day.ago)
      .having("COUNT(ratings.id) >= ?", MIN_RATINGS)
      .preload(:film, :ratings)
      .sort_by { |s| -s.ratings.size }
  end

  def text
    selections = premiere_selections.dup
    tweet = build_tweet(selections)
    until tweet.length <= 280
      selections.pop
      break if selections.empty?

      tweet = build_tweet(selections)
    end
    tweet
  end

  def post!
    client.post("tweets", { text: text }.to_json)
  end

  private

  def build_tweet(films)
    header + film_lines(films) + footer
  end

  def header
    "#{edition.code}: #{Time.zone.today.strftime("%B %-d")} Recap\n\n"
  end

  def film_lines(films)
    films.map do |selection|
      last_name = selection.film.directors.first.split(" ").last
      avg = number_to_rounded(selection.average_rating, precision: 2)
      "#{selection.film.title.upcase} (#{last_name}): #{avg} from #{pluralize(selection.ratings.size, "rating")}"
    end.join("\n") + "\n\n"
  end

  def footer
    "Check out all of our critics scores from the festival here: #{edition_url(edition)}"
  end

  def edition_url(edition)
    Rails.application.routes.url_helpers.edition_url(
      edition,
      Rails.application.config.action_mailer.default_url_options,
    )
  end

  def client
    @client ||= X::Client.new(**Rails.application.credentials.x)
  end
end
