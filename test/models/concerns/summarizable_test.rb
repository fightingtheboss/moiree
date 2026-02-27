# frozen_string_literal: true

require "test_helper"

class SummarizableTest < ActiveSupport::TestCase
  # Tests use Edition as the primary includer since it has a direct
  # `selections` association and needs no override of `summary_selections`.
  #
  # Fixture data (both selections at editions(:base), each with 4 ratings):
  #   base selection:              3.5, 2.5, 1.0, 1.5  → avg_rating 3.5 → bombe moirée
  #   with_original_title:         4.5, 0.0, 5.0, 1.0  → avg_rating 4.5 → most divisive
  #
  # This also provides a 5.0 rating and a 0.0 rating for five/zero star queries.

  setup do
    @edition = editions(:base)
  end

  # --- bombe_moiree ---

  test "#bombe_moiree returns the lowest-rated selection with enough ratings" do
    result = @edition.bombe_moiree

    assert_equal(selections(:base), result, "Should return the selection with the lowest average_rating")
  end

  test "#bombe_moiree returns nil on an edition with no qualifying selections" do
    assert_nil(editions(:with_no_films).bombe_moiree)
  end

  # --- most_divisive ---

  test "#most_divisive returns the selection with the highest standard deviation" do
    result = @edition.most_divisive

    assert_equal(
      selections(:with_original_title),
      result,
      "Scores [4.5, 0.0, 5.0, 1.0] should have a higher std dev than [3.5, 2.5, 1.0, 1.5]",
    )
  end

  test "#most_divisive returns nil on an edition with no qualifying selections" do
    assert_nil(editions(:with_no_films).most_divisive)
  end

  # --- build_histogram ---

  test "#build_histogram returns empty hash for nil selection" do
    assert_equal({}, @edition.build_histogram(nil))
  end

  test "#build_histogram returns a complete histogram with all 11 score buckets" do
    histogram = @edition.build_histogram(selections(:base))

    expected_scores = (0..5).step(0.5).map(&:to_d)
    assert_equal(expected_scores, histogram.keys)
  end

  test "#build_histogram counts ratings at each score correctly" do
    histogram = @edition.build_histogram(selections(:base))

    assert_equal(1, histogram[BigDecimal("3.5")])
    assert_equal(1, histogram[BigDecimal("2.5")])
    assert_equal(1, histogram[BigDecimal("1.0")])
    assert_equal(1, histogram[BigDecimal("1.5")])
    assert_equal(0, histogram[BigDecimal("5.0")])
  end

  # --- bombe_moiree_histogram / most_divisive_histogram ---

  test "#bombe_moiree_histogram returns empty hash when no bombe moiree exists" do
    assert_equal({}, editions(:with_no_films).bombe_moiree_histogram)
  end

  test "#bombe_moiree_histogram returns histogram for the bombe moiree selection" do
    histogram = @edition.bombe_moiree_histogram

    assert_equal(11, histogram.size)
    assert_equal(1, histogram[BigDecimal("3.5")])
  end

  test "#most_divisive_histogram returns empty hash when no most divisive exists" do
    assert_equal({}, editions(:with_no_films).most_divisive_histogram)
  end

  test "#most_divisive_histogram returns histogram for the most divisive selection" do
    histogram = @edition.most_divisive_histogram

    assert_equal(11, histogram.size)
    assert_equal(1, histogram[BigDecimal("5.0")])
    assert_equal(1, histogram[BigDecimal("0.0")])
  end

  # --- five_star_ratings ---

  test "#five_star_ratings returns ratings with a score of 5.0" do
    result = @edition.five_star_ratings

    assert_equal(1, result.size)
    assert(result.all? { |r| r.score == 5.0 })
  end

  test "#five_star_ratings returns empty relation when there are none" do
    assert_empty(editions(:with_no_films).five_star_ratings)
  end

  test "#five_star_ratings are ordered by film title" do
    titles = @edition.five_star_ratings.map { |r| r.film.title }

    assert_equal(titles.sort, titles)
  end

  # --- zero_star_ratings ---

  test "#zero_star_ratings returns ratings with a score of 0.0" do
    result = @edition.zero_star_ratings

    assert_equal(1, result.size)
    assert(result.all? { |r| r.score == 0.0 })
  end

  test "#zero_star_ratings returns empty relation when there are none" do
    assert_empty(editions(:with_no_films).zero_star_ratings)
  end

  # --- MIN_RATINGS_FOR_SUMMARY constant ---

  test "MIN_RATINGS_FOR_SUMMARY is accessible as a constant" do
    assert_equal(4, Summarizable::MIN_RATINGS_FOR_SUMMARY)
  end

  # --- summary_selections default ---

  test "#summary_selections defaults to the selections association on Edition" do
    assert_equal(@edition.selections.order(:id).to_a, @edition.summary_selections.order(:id).to_a)
  end
end
