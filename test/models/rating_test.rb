# frozen_string_literal: true

require "test_helper"

class RatingTest < ActiveSupport::TestCase
  test "should not be valid if score is below 0" do
  end

  test "should not be valid if score is above 5" do
  end

  test "should not be valid if score is formatted incorrectly" do
  end

  test "should not be valid if required fields are not present" do
  end

  test "should be valid with all required fields present" do
  end

  test "#film should return the Film associated with the Rating" do
    rating = ratings(:base)
    film = films(:base)

    assert_equal film, rating.film
  end

  test "should update Film#overall_average_rating when a new Rating is created" do
  end

  test "should update Film#overall_average_rating when a new Rating is destroyed" do
  end
end
