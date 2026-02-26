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

  test "#top_selections_with_includes returns YearInReviewTopSelection records with eager-loaded associations" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    top_selections = year_in_review.top_selections_with_includes

    assert_kind_of(ActiveRecord::Relation, top_selections)
    top_selections.each do |ts|
      assert_kind_of(YearInReviewTopSelection, ts)
    end
  end

  test "#generate! aggregates ratings across multiple editions for the same film" do
    # Create a second edition in the same year (2024) at a different festival
    second_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2024,
      code: "CANNES24",
      start_date: "2024-05-14",
      end_date: "2024-05-25",
      slug: "cannes24",
    )

    # Create a category for the second edition
    category = Category.create!(edition: second_edition, name: "Competition", position: 1)

    # The base film (year: 2024) already has a selection at editions(:base)
    film = films(:base)

    # Create a second selection for the same film at the second edition
    second_selection = Selection.create!(edition: second_edition, film: film, category: category)

    # Create attendance records for critics at both editions
    Attendance.create!(critic: critics(:without_publication), edition: second_edition)
    Attendance.create!(critic: critics(:without_ratings), edition: second_edition)

    # Existing ratings on base selection: base critic (3.5), without_publication (2.5) = 2 ratings
    # Add two more ratings on the SECOND selection to hit the >=4 threshold across editions
    Rating.create!(critic: critics(:without_publication), selection: second_selection, score: 4.0,
      skip_cache_average_ratings_callback: true)
    Rating.create!(critic: critics(:without_ratings), selection: second_selection, score: 5.0,
      skip_cache_average_ratings_callback: true)

    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    top = year_in_review.top_selections_with_includes.to_a
    top_for_film = top.find { |ts| ts.selection.film_id == film.id }

    assert_not_nil(top_for_film, "Film should appear in top selections via cross-edition aggregation")
    # Total: 4 ratings (3.5 + 2.5 + 4.0 + 5.0) = 15.0 / 4 = 3.75
    assert_equal(4, top_for_film.combined_ratings_count)
    assert_in_delta(3.75, top_for_film.combined_average_rating.to_f, 0.01)
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

  test ".for returns a generated YearInReview for the given year" do
    year_in_review = YearInReview.for(year_in_reviews(:base).year)

    assert_kind_of(YearInReview, year_in_review)
    assert_not_nil(year_in_review.generated_at)
    assert(year_in_review.persisted?)
  end

  test ".for creates a new record if one does not exist" do
    assert_difference("YearInReview.count", 1) do
      YearInReview.for(2029)
    end
  end

  test ".for returns existing record without regenerating if fresh" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!
    original_generated_at = year_in_review.generated_at

    result = YearInReview.for(year_in_review.year)

    assert_equal(original_generated_at, result.generated_at)
  end

  test ".current returns a YearInReview for the current year" do
    year_in_review = YearInReview.current

    assert_kind_of(YearInReview, year_in_review)
    assert_equal(Date.current.year, year_in_review.year)
    assert_not_nil(year_in_review.generated_at)
  end
end
