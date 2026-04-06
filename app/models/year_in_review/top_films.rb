# frozen_string_literal: true

class YearInReview
  class TopFilms
    DEFAULT_LIMIT = 5

    Result = Data.define(:film_id, :bayesian_score, :average_rating, :ratings_count)

    def initialize(film_aggregates, limit: DEFAULT_LIMIT)
      @film_aggregates = film_aggregates
      @limit = limit
    end

    def ranked
      return [] if @film_aggregates.empty?

      @film_aggregates
        .map { |agg| build_result(agg) }
        .sort_by { |r| -r.bayesian_score }
        .first(@limit)
    end

    private

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
