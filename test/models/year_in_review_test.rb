# frozen_string_literal: true

require "test_helper"

class YearInReviewTest < ActiveSupport::TestCase
  test "should not be valid without a year" do
    year_in_review = YearInReview.new

    assert_not(year_in_review.valid?)
    assert_includes(year_in_review.errors[:year], "can't be blank")
  end

  test "should not be valid with a duplicate year" do
    year_in_review = YearInReview.new(year: year_in_reviews(:base).year)

    assert_not(year_in_review.valid?)
    assert_includes(year_in_review.errors[:year], "has already been taken")
  end

  test "should not be valid with a year less than or equal to 2023" do
    year_in_review = YearInReview.new(year: 2023)

    assert_not(year_in_review.valid?)
  end

  test "should be valid with a unique year greater than 2023" do
    year_in_review = YearInReview.new(year: 2025)

    assert(year_in_review.valid?)
  end

  test "#editions returns editions within the year" do
    year_in_review = year_in_reviews(:base)
    edition = editions(:base)

    assert_includes(year_in_review.editions, edition)
  end

  test "#stale? returns true when generated_at is nil" do
    year_in_review = YearInReview.new(year: 2025)

    assert(year_in_review.stale?)
  end

  test "#stale? returns false when generated_at is recent and no editions updated" do
    year_in_review = year_in_reviews(:base)
    year_in_review.update!(generated_at: Time.current)

    assert_not(year_in_review.stale?)
  end

  test "#generate! populates stats from editions" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    assert_not_nil(year_in_review.generated_at)
    assert(year_in_review.editions_count >= 0)
    assert(year_in_review.critics_count >= 0)
    assert(year_in_review.films_count >= 0)
    assert(year_in_review.ratings_count >= 0)
  end

  test "#generate! with no editions sets zero counts" do
    year_in_review = YearInReview.create!(year: 2030)
    year_in_review.generate!

    assert_equal(0, year_in_review.editions_count)
    assert_equal(0, year_in_review.critics_count)
    assert_equal(0, year_in_review.films_count)
    assert_equal(0, year_in_review.ratings_count)
    assert_not_nil(year_in_review.generated_at)
  end

  test "#top_selections_with_includes returns selections with eager-loaded associations" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    selections = year_in_review.top_selections_with_includes

    assert_kind_of(ActiveRecord::Relation, selections)
  end

  test "has many top_selections through year_in_review_top_selections" do
    year_in_review = year_in_reviews(:base)

    assert_respond_to(year_in_review, :top_selections)
    assert_respond_to(year_in_review, :year_in_review_top_selections)
  end

  test "#bombe_moiree_histogram returns empty hash when no bombe moiree" do
    year_in_review = YearInReview.new(year: 2030)

    assert_equal({}, year_in_review.bombe_moiree_histogram)
  end

  test "#most_divisive_histogram returns empty hash when no most divisive" do
    year_in_review = YearInReview.new(year: 2030)

    assert_equal({}, year_in_review.most_divisive_histogram)
  end
end
