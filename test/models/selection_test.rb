# frozen_string_literal: true

require "test_helper"

class SelectionTest < ActiveSupport::TestCase
  test "should not be valid if required fields are not present" do
    selection = Selection.new

    assert_not(selection.valid?)
  end

  test "should be valid with all required fields present" do
    selection = selections(:base)

    assert(selection.valid?)
  end

  test "#cache_average_rating should update the average_rating attribute of the Selection" do
    selection = selections(:base)
    rating = ratings(:base)

    selection.update(average_rating: nil)
    rating.update(score: 4.5)

    selection.cache_average_rating

    assert_equal 4.5, selection.reload.average_rating
  end

  test "#cache_average_rating excludes walked out ratings from the average" do
    selection = selections(:base)
    critic = critics(:without_publication)
    Attendance.create!(critic: critic, edition: selection.edition)

    Rating.create!(
      score: 5.0,
      critic: critic,
      selection: selection,
      walked_out: true,
      skip_cache_average_ratings_callback: true,
    )

    selection.update!(average_rating: nil)
    selection.cache_average_rating

    assert_equal(3.5, selection.reload.average_rating.to_f)
  end
end
