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
      { film_id: 1, sum: 200.0, count: 50 },  # avg 4.0, many ratings
      { film_id: 2, sum: 5.0, count: 2 },      # avg 2.5, few ratings
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    result = top_films.ranked.find { |r| r.film_id == 1 }
    assert_in_delta(4.0, result.bayesian_score, 0.2)
  end

  test "film with few ratings is pulled toward the global mean" do
    aggregates = [
      { film_id: 1, sum: 200.0, count: 50 },  # avg 4.0, many ratings
      { film_id: 2, sum: 10.0, count: 2 },     # avg 5.0, few ratings
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    result = top_films.ranked.find { |r| r.film_id == 2 }
    # Raw average is 5.0, but Bayesian score should be pulled down toward global mean
    assert_operator(result.bayesian_score, :<, 5.0)
    assert_operator(result.bayesian_score, :>, result.average_rating - 1.5)
  end

  test "film with few but perfect ratings can rank above a film with many mediocre ratings" do
    aggregates = [
      { film_id: 1, sum: 15.0, count: 5 },   # avg 3.0, mediocre
      { film_id: 2, sum: 15.0, count: 3 },    # avg 5.0, excellent but fewer ratings
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    results = top_films.ranked
    assert_equal(2, results.first.film_id, "Highly-rated film with fewer ratings should rank first")
  end

  test "all films with the same average produce equal bayesian scores" do
    aggregates = [
      { film_id: 1, sum: 20.0, count: 5 },   # avg 4.0
      { film_id: 2, sum: 40.0, count: 10 },   # avg 4.0
      { film_id: 3, sum: 8.0, count: 2 },     # avg 4.0
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
      { film_id: 1, sum: 100.0, count: 25 },  # avg 4.0
      { film_id: 2, sum: 10.0, count: 2 },     # avg 5.0
    ]
    top_films = YearInReview::TopFilms.new(aggregates)

    result = top_films.ranked.find { |r| r.film_id == 2 }
    assert_in_delta(5.0, result.average_rating, 0.01, "Raw average should be preserved")
    assert_operator(result.bayesian_score, :<, 5.0, "Bayesian score should differ from raw average")
  end
end
