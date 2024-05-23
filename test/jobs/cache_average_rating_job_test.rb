# frozen_string_literal: true

require "test_helper"

class CacheAverageRatingJobTest < ActiveJob::TestCase
  test "cache average rating" do
    selection = selections(:base)
    rating = ratings(:base)

    selection.update(average_rating: nil)
    rating.update(score: 4.5)

    CacheAverageRatingJob.perform_now(selection)

    assert_equal 4.5, selection.reload.average_rating
  end

  test "cache overall average rating" do
    rating = ratings(:base)

    rating.film.update(overall_average_rating: nil)
    rating.update(score: 4.5)

    CacheAverageRatingJob.perform_now(rating.selection)

    assert_equal 3.5, rating.film.reload.overall_average_rating
  end
end
