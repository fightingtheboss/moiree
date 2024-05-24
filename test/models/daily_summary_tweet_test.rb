# frozen_string_literal: true

require "test_helper"

class DailySummaryTweetTest < ActiveSupport::TestCase
  test "#ratings should return all ratings from the last 24h for the edition" do
    edition = editions(:base)
    rating = ratings(:base)

    Rating.create!(
      edition: edition,
      critic: critics(:without_ratings),
      selection: selections(:base),
      score: 4.5,
      created_at: 25.hours.ago,
    )

    assert(DailySummaryTweet.new(edition).ratings.include?(rating))
    assert_equal(3, DailySummaryTweet.new(edition).ratings.count)
  end

  test "#critics should return all critics who rated films in the last 24h" do
    edition = editions(:base)

    Rating.create!(
      edition: edition,
      critic: critics(:without_ratings),
      selection: selections(:base),
      score: 4.5,
      created_at: 25.hours.ago,
    )

    assert_equal(2, DailySummaryTweet.new(edition).critics.count)
  end

  test "#selections should return all selections that were rated in the last 24h" do
    edition = editions(:base)

    Rating.create!(
      edition: edition,
      critic: critics(:without_ratings),
      selection: selections(:base),
      score: 4.5,
      created_at: 25.hours.ago,
    )

    assert_equal(2, DailySummaryTweet.new(edition).selections.count)
  end

  test "#films should return all films that were rated in the last 24h" do
    edition = editions(:base)

    Rating.create!(
      edition: edition,
      critic: critics(:without_ratings),
      selection: selections(:base),
      score: 4.5,
      created_at: 25.hours.ago,
    )

    assert_equal(2, DailySummaryTweet.new(edition).films.count)
  end

  test "#trending should return the top and bottom films by average rating" do
    edition = editions(:base)
    edition.selections.find_each(&:cache_average_rating)

    summary = DailySummaryTweet.new(edition)

    assert_equal(2, summary.trending.first.count)
    assert_equal(2, summary.trending.last.count)
  end

  test "#header should return the header text for the tweet" do
    edition = editions(:base)
    edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)

    summary = DailySummaryTweet.new(edition)
    header = summary.header

    assert_match(/TIFF24 Day 8 Ratings/, header)
    assert_match(/2 critics/, header)
    assert_match(/2 films/, header)
  end

  test "#film_lists should return the top and bottom films by average rating" do
    edition = editions(:base)
    edition.selections.find_each(&:cache_average_rating)

    summary = DailySummaryTweet.new(edition)
    film_lists = summary.film_lists

    assert_match(/Top 2 \(avg\)/, film_lists)
    assert_match(/Bottom 2 \(avg\)/, film_lists)
  end

  test "#text should return the full tweet text" do
    edition = editions(:base)
    edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
    edition.selections.find_each(&:cache_average_rating)

    tweet = <<~TWEET
      ⭐️ TIFF24 Day 8 Ratings ⭐️
      There were 3 ratings from 2 critics across 2 films
      http://localhost:3000/editions/tiff24

      Top 2 (avg)
      • With Original Title → 4.5
      • Festival Film → 3.5

      Bottom 2 (avg)
      • With Original Title → 4.5
      • Festival Film → 3.5
    TWEET

    assert_equal DailySummaryTweet.new(edition).text, tweet
  end

  # TODO: Flesh out all of the tests around the tweet length logic

  # test "#text should return a shorter tweet if the full tweet is too long" do
  #   edition = editions(:base)
  #   edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
  #   edition.selections.find_each(&:cache_average_rating)

  #   tweet = <<~TWEET
  #     ⭐️ TIFF24 Day 8 Ratings ⭐️
  #     There were 3 ratings from 2 critics across 2 films
  #     http://localhost:3000/editions/tiff24

  #     Top 1 (avg)
  #     • With Original Title → 4.5

  #     Bottom 1 (avg)
  #     • With Original Title → 4.5
  #   TWEET

  #   assert_equal DailySummaryTweet.new(edition).text, tweet
  # end

  test "#post! should post the tweet to the API" do
    edition = editions(:base)
    edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
    edition.selections.find_each(&:cache_average_rating)

    tweet = <<~TWEET
      ⭐️ TIFF24 Day 8 Ratings ⭐️
      There were 3 ratings from 2 critics across 2 films
      http://localhost:3000/editions/tiff24

      Top 2 (avg)
      • With Original Title → 4.5
      • Festival Film → 3.5

      Bottom 2 (avg)
      • With Original Title → 4.5
      • Festival Film → 3.5
    TWEET

    X::Client.any_instance.expects(:post).with("tweets", { text: tweet }.to_json).returns(true)

    DailySummaryTweet.new(edition).post!
  end
end
