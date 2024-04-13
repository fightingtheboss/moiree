# frozen_string_literal: true

require "test_helper"

class RatingTest < ActiveSupport::TestCase
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

  test "#film should return the Film associated with the Rating" do
    rating = ratings(:base)
    film = films(:base)

    assert_equal(film, rating.film)
  end

  test "should call Film#overall_average_rating when a new Rating is created" do
    rating = Rating.new(score: 5, critic: critics(:without_ratings), selection: selections(:base))
    rating.film.expects(:cache_overall_average_rating)

    rating.save
  end

  test "should call Film#overall_average_rating when a Rating is destroyed" do
    rating = ratings(:base)
    rating.film.expects(:cache_overall_average_rating)

    rating.destroy
  end
end
