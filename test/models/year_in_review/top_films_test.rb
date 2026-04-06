# frozen_string_literal: true

require "test_helper"

class YearInReview::TopFilmsTest < ActiveSupport::TestCase
  test "returns empty array when given no aggregates" do
    top_films = YearInReview::TopFilms.new([])

    assert_equal([], top_films.ranked)
  end

  test "returns a single film when given one aggregate" do
    aggregates = [{ film_id: 1, sum: 15.0, count: 5 }]
    top_films = YearInReview::TopFilms.new(aggregates)

    results = top_films.ranked
    assert_equal(1, results.size)
    assert_equal(1, results.first.film_id)
    assert_in_delta(3.0, results.first.bayesian_score, 0.01)
    assert_in_delta(3.0, results.first.average_rating, 0.01)
    assert_equal(5, results.first.ratings_count)
  end

  test "film with many ratings ranks close to its raw average" do
    aggregates = [
      { film_id: 1, sum: 200.0, count: 50 }, # avg 4.0, many ratings
      { film_id: 2, sum: 20.0, count: 5 },   # avg 4.0, fewer ratings
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    result = top_films.ranked.find { |r| r.film_id == 1 }
    assert_in_delta(4.0, result.bayesian_score, 0.2)
  end

  test "film with few ratings is pulled toward the global mean" do
    aggregates = [
      { film_id: 1, sum: 200.0, count: 50 }, # avg 4.0, many ratings
      { film_id: 2, sum: 25.0, count: 5 },   # avg 5.0, few ratings
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    result = top_films.ranked.find { |r| r.film_id == 2 }
    # Raw average is 5.0, but Bayesian score should be pulled down toward global mean
    assert_operator(result.bayesian_score, :<, 5.0)
    assert_operator(result.bayesian_score, :>, result.average_rating - 1.5)
  end

  test "film with few but perfect ratings can rank above a film with many mediocre ratings" do
    aggregates = [
      { film_id: 1, sum: 15.0, count: 5 }, # avg 3.0, mediocre
      { film_id: 2, sum: 25.0, count: 5 }, # avg 5.0, excellent
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    results = top_films.ranked
    assert_equal(2, results.first.film_id, "Highly-rated film should rank first")
  end

  test "all films with the same average produce equal bayesian scores" do
    aggregates = [
      { film_id: 1, sum: 20.0, count: 5 },  # avg 4.0
      { film_id: 2, sum: 40.0, count: 10 }, # avg 4.0
      { film_id: 3, sum: 32.0, count: 8 },  # avg 4.0
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    results = top_films.ranked
    scores = results.map(&:bayesian_score).uniq
    # When all raw averages equal the global mean, Bayesian scores should all equal the global mean
    assert_equal(1, scores.size, "All Bayesian scores should be equal when averages are identical")
  end

  test "all films with the same count degenerates to simple average ranking" do
    aggregates = [
      { film_id: 1, sum: 15.0, count: 5 },   # avg 3.0
      { film_id: 2, sum: 20.0, count: 5 },   # avg 4.0
      { film_id: 3, sum: 12.5, count: 5 },   # avg 2.5
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    results = top_films.ranked
    assert_equal([2, 1, 3], results.map(&:film_id))
  end

  test "returns at most the specified limit" do
    aggregates = (1..10).map do |i|
      { film_id: i, sum: i * 5.0, count: 5 }
    end

    top_films = YearInReview::TopFilms.new(aggregates, limit: 3)
    assert_equal(3, top_films.ranked.size)
  end

  test "uses DEFAULT_LIMIT when no limit is specified" do
    aggregates = (1..10).map do |i|
      { film_id: i, sum: i * 5.0, count: 5 }
    end

    top_films = YearInReview::TopFilms.new(aggregates)
    assert_equal(YearInReview::TopFilms::DEFAULT_LIMIT, top_films.ranked.size)
  end

  test "result includes raw average and ratings count alongside bayesian score" do
    aggregates = [{ film_id: 1, sum: 20.0, count: 5 }]
    top_films = YearInReview::TopFilms.new(aggregates)

    result = top_films.ranked.first
    assert_in_delta(4.0, result.average_rating, 0.01)
    assert_equal(5, result.ratings_count)
    assert_respond_to(result, :bayesian_score)
  end

  test "preserves raw average even when bayesian score differs" do
    aggregates = [
      { film_id: 1, sum: 100.0, count: 25 }, # avg 4.0
      { film_id: 2, sum: 30.0, count: 6 },   # avg 5.0
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    result = top_films.ranked.find { |r| r.film_id == 2 }
    assert_in_delta(5.0, result.average_rating, 0.01, "Raw average should be preserved")
    assert_operator(result.bayesian_score, :<, 5.0, "Bayesian score should differ from raw average")
  end

  # --- min_ratings filtering ---

  test "excludes films below the default min_ratings floor" do
    aggregates = [
      { film_id: 1, sum: 20.0, count: 5 },  # avg 4.0, above floor
      { film_id: 2, sum: 15.0, count: 3 },  # avg 5.0, below floor of 4
      { film_id: 3, sum: 16.0, count: 4 },  # avg 4.0, at the floor
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    results = top_films.ranked
    film_ids = results.map(&:film_id)
    assert_includes(film_ids, 1)
    assert_includes(film_ids, 3)
    assert_not_includes(film_ids, 2, "Film with 3 ratings should be excluded (below floor of 4)")
  end

  test "uses custom min_ratings when specified" do
    aggregates = [
      { film_id: 1, sum: 40.0, count: 10 }, # avg 4.0
      { film_id: 2, sum: 30.0, count: 6 },  # avg 5.0
      { film_id: 3, sum: 12.0, count: 4 },  # avg 3.0
    ]
    top_films = YearInReview::TopFilms.new(aggregates, min_ratings: 5)

    results = top_films.ranked
    film_ids = results.map(&:film_id)
    assert_includes(film_ids, 1)
    assert_includes(film_ids, 2)
    assert_not_includes(film_ids, 3, "Film with 4 ratings should be excluded (below custom min of 5)")
  end

  test "min_ratings of zero allows all films" do
    aggregates = [
      { film_id: 1, sum: 5.0, count: 1 },
      { film_id: 2, sum: 20.0, count: 5 },
    ]
    top_films = YearInReview::TopFilms.new(aggregates, min_ratings: 0)

    assert_equal(2, top_films.ranked.size, "All films should be included with min_ratings: 0")
  end

  test "returns empty when all films are below min_ratings" do
    aggregates = [
      { film_id: 1, sum: 5.0, count: 1 },
      { film_id: 2, sum: 10.0, count: 3 },
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    assert_equal([], top_films.ranked, "No films should qualify when all are below the floor")
  end

  test "global mean is computed from all films including those below min_ratings" do
    # Film 1: avg 4.0 (qualifies), Film 2: avg 2.0 (below floor, but affects global mean)
    # If global mean only used qualifying films it would be 4.0.
    # Including film 2, global mean = (20 + 4) / (5 + 2) = 24/7 ≈ 3.43
    aggregates = [
      { film_id: 1, sum: 20.0, count: 5 }, # avg 4.0
      { film_id: 2, sum: 4.0, count: 2 },  # avg 2.0, below floor
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    result = top_films.ranked.first
    # If global mean were 4.0 (only qualifying), bayesian score would equal 4.0 exactly.
    # With the lower global mean from the full pool, the Bayesian score should be pulled
    # slightly below the raw average of 4.0.
    assert_operator(
      result.bayesian_score,
      :<,
      4.0,
      "Bayesian prior should reflect all films, pulling score below 4.0",
    )
  end

  test "DEFAULT_MIN_RATINGS matches Summarizable::MIN_RATINGS_FLOOR" do
    assert_equal(Summarizable::MIN_RATINGS_FLOOR, YearInReview::TopFilms::DEFAULT_MIN_RATINGS)
  end
end
