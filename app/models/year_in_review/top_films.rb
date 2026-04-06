# frozen_string_literal: true

class YearInReview
  class TopFilms
    DEFAULT_LIMIT = 5
    DEFAULT_MIN_RATINGS = Summarizable::MIN_RATINGS_FLOOR

    Result = Data.define(:film_id, :bayesian_score, :average_rating, :ratings_count)

    # film_aggregates - Array of { film_id:, sum:, count: } hashes for every
    #   rated film in the year (before any filtering).
    # min_ratings - Films with fewer ratings are excluded from ranking.
    #   The global mean and confidence weight are computed from the full
    #   (unfiltered) pool so the Bayesian prior isn't skewed by survivorship.
    # limit - Maximum number of results to return.
    def initialize(film_aggregates, min_ratings: DEFAULT_MIN_RATINGS, limit: DEFAULT_LIMIT)
      @film_aggregates = film_aggregates
      @min_ratings = min_ratings
      @limit = limit
    end

    def ranked
      return [] if @film_aggregates.empty?

      qualifying_aggregates
        .map { |agg| build_result(agg) }
        .sort_by { |r| -r.bayesian_score }
        .first(@limit)
    end

    private

    def qualifying_aggregates
      @qualifying_aggregates ||= @film_aggregates.select { |agg| agg[:count] >= @min_ratings }
    end

    def build_result(aggregate)
      Result.new(
        film_id: aggregate[:film_id],
        bayesian_score: bayesian_score(sum: aggregate[:sum], count: aggregate[:count]),
        average_rating: aggregate[:sum].to_f / aggregate[:count],
        ratings_count: aggregate[:count],
      )
    end

    def bayesian_score(sum:, count:)
      (confidence_weight * global_mean + sum) / (confidence_weight + count)
    end

    # Computed from ALL films (pre-filter) so the prior reflects the true
    # population mean, not just the survivors above the min_ratings cutoff.
    def global_mean
      @global_mean ||= begin
        total_sum = @film_aggregates.sum { |agg| agg[:sum] }
        total_count = @film_aggregates.sum { |agg| agg[:count] }
        total_sum.to_f / total_count
      end
    end

    def confidence_weight
      @confidence_weight ||= begin
        total_count = @film_aggregates.sum { |agg| agg[:count] }
        total_count.to_f / @film_aggregates.size
      end
    end
  end
end
