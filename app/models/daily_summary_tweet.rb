# frozen_string_literal: true

class DailySummaryTweet
  # TODO: This class might be better as a ViewObject or a regular view with a template
  #       Including these helpers here is a bit of a smell
  include ActionView::Helpers::TextHelper, ActiveSupport::NumberHelper

  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def ratings
    # Grab the ratings for the current edition in the last 24 hours
    @ratings ||= edition.ratings.includes(:critic, :selection, :film).where(
      "ratings.created_at > ?",
      1.day.ago,
    ).order(:created_at)
  end

  def critics
    ratings.map(&:critic).uniq
  end

  def selections
    @selections ||= ratings.map(&:selection).uniq
  end

  def films
    @films ||= ratings.map(&:film).uniq
  end

  def trending(num_films: 3)
    num_films = [num_films, selections.count].min
    sorted = selections.sort_by(&:average_rating).reverse!

    [sorted[0..(num_films - 1)], sorted[-num_films..-1]]
  end

  def header
    <<~HEADER
      ⭐️ #{edition.code} Day #{edition.current_day} Ratings ⭐️
      There were #{pluralize(ratings.count, "rating")} from #{pluralize(critics.count, "critic")} across #{pluralize(films.count, "film")}
      #{edition_url(edition)}
    HEADER
  end

  def film_lists(num_films: 3)
    top, bottom = trending(num_films: num_films)

    film_list(type: :top, selections: top) + line_break + film_list(type: :bottom, selections: bottom)
  end

  def film_list(type: :top, selections: [])
    <<~FILM_LIST
      #{type.capitalize} #{selections.size == 1 ? "" : selections.size} (avg)
      #{film_list_items(selections)}
    FILM_LIST
  end

  def text
    num_films = 3
    tweet = header + line_break + film_lists

    until tweet.chars.size <= 280
      if num_films > 0
        num_films -= 1
        tweet = header + line_break + film_lists(num_films: num_films)
      else
        tweet = header + line_break + "Visit the link for detailed ratings"
      end
    end

    tweet
  end

  def post!
    client.post("tweets", { text: text }.to_json)
  end

  private

  def edition_url(edition)
    Rails.application.routes.url_helpers.edition_url(
      edition,
      Rails.application.config.action_mailer.default_url_options,
    )
  end

  def client
    @client ||= X::Client.new(**Rails.application.credentials.x)
  end

  def film_list_items(selections)
    selections.map do |selection|
      "• #{selection.film.title} → #{number_to_rounded(selection.average_rating, precision: 2)}"
    end.join("\n")
  end

  def line_break
    "\n"
  end
end
