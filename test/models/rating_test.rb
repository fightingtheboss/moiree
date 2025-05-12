# frozen_string_literal: true

require "test_helper"

class RatingTest < ActiveSupport::TestCase
  test "should be valid with a score of 0" do
    rating = Rating.new(
      score: 0,
      critic: critics(:without_ratings),
      selection: selections(:base),
    )

    assert rating.valid?
  end

  test "should be valid with a score with one decimal place" do
    rating = Rating.new(
      score: 3.5,
      critic: critics(:without_ratings),
      selection: selections(:base),
    )

    assert rating.valid?
  end

  test "should not be valid if score is below 0" do
    rating = Rating.new(score: -1)

    assert_not(rating.valid?)
  end

  test "should not be valid if score is above 5" do
    rating = Rating.new(score: 6)

    assert_not(rating.valid?)
  end

  test "should not be valid if score is formatted incorrectly" do
    rating = Rating.new(score: 2.75)

    assert_not(rating.valid?)
  end

  test "should not be valid if required fields are not present" do
    rating = Rating.new

    assert_not(rating.valid?)
  end

  test "should be valid with all required fields present" do
    rating = ratings(:base)

    assert(rating.valid?)
  end

  test "should not be valid if critic has already rated this film's selection" do
    existing_rating = ratings(:base)
    new_rating = Rating.new(
      score: 4,
      critic: existing_rating.critic,
      selection: existing_rating.selection,
    )

    assert_not new_rating.valid?
    assert_includes new_rating.errors.full_messages, "#{existing_rating.critic.name} has already rated #{existing_rating.film.title}"
  end

  test "should be valid with a valid review_url" do
    rating = Rating.new(
      score: 5,
      critic: critics(:without_ratings),
      selection: selections(:base),
      review_url: "https://example.com/review",
    )

    assert rating.valid?
  end

  test "should not be valid with an invalid review_url" do
    rating = Rating.new(
      score: 5,
      critic: critics(:without_ratings),
      selection: selections(:base),
      review_url: "invalid-url",
    )

    assert_not rating.valid?
    assert_includes rating.errors.full_messages, "Review url must be a valid URL"
  end

  test "should be valid with a blank review_url" do
    rating = Rating.new(
      score: 5,
      critic: critics(:without_ratings),
      selection: selections(:base),
      review_url: "",
    )

    assert rating.valid?
  end

  test "should be valid with an impression under 500 characters" do
    rating = Rating.new(
      score: 5,
      critic: critics(:without_ratings),
      selection: selections(:base),
      impression: "This is a great film.",
    )

    assert rating.valid?
  end

  test "should not be valid with an impression over 500 characters" do
    rating = Rating.new(
      score: 5,
      critic: critics(:without_ratings),
      selection: selections(:base),
      impression: "a" * 501,
    )

    assert_not rating.valid?
    assert_includes rating.errors.full_messages, "Impression is too long (maximum is 500 characters)"
  end

  test "#edition should return the Edition associated with the Rating" do
    rating = ratings(:base)

    assert_equal rating.selection.edition, rating.edition
  end

  test "#film should return the Film associated with the Rating" do
    rating = ratings(:base)
    film = films(:base)

    assert_equal(film, rating.film)
  end

  test "should enqueue a CacheAverageRatingJob when a new Rating is created" do
    rating = Rating.new(score: 5, critic: critics(:without_ratings), selection: selections(:base))
    CacheAverageRatingJob.expects(:perform_later).with(rating.selection)

    rating.save
  end

  test "should enqueue a CacheAverageRatingJob when a Rating is destroyed" do
    rating = ratings(:base)
    CacheAverageRatingJob.expects(:perform_later).with(rating.selection)

    rating.destroy
  end

  test "should not enqueue CacheAverageRatingJob when skip_cache_average_ratings_callback is true" do
    rating = Rating.new(
      score: 5,
      critic: critics(:without_ratings),
      selection: selections(:base),
      skip_cache_average_ratings_callback: true,
    )

    CacheAverageRatingJob.expects(:perform_later).never

    rating.save
  end
end
