# frozen_string_literal: true

require "test_helper"

class YearInReviewTopSelectionTest < ActiveSupport::TestCase
  test "should not be valid without a position" do
    top_selection = YearInReviewTopSelection.new(
      year_in_review: year_in_reviews(:base),
      selection: selections(:base),
    )

    assert_not(top_selection.valid?)
  end

  test "should not allow duplicate selection for same year_in_review" do
    existing = year_in_review_top_selections(:first)
    duplicate = YearInReviewTopSelection.new(
      year_in_review: existing.year_in_review,
      selection: existing.selection,
      position: 99,
    )

    assert_not(duplicate.valid?)
  end

  test "should not allow duplicate position for same year_in_review" do
    existing = year_in_review_top_selections(:first)
    duplicate = YearInReviewTopSelection.new(
      year_in_review: existing.year_in_review,
      selection: selections(:with_original_title),
      position: existing.position,
    )

    assert_not(duplicate.valid?)
  end

  test "should be valid with unique selection and position" do
    top_selection = YearInReviewTopSelection.new(
      year_in_review: year_in_reviews(:base),
      selection: selections(:with_original_title),
      position: 2,
    )

    assert(top_selection.valid?)
  end
end
