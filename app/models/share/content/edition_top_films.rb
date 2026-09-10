# frozen_string_literal: true

module Share
  module Content
    class EditionTopFilms < Base
      DEFAULT_LIMIT = 5

      Slide = Data.define(:selection, :rank, :bayesian_score)

      def initialize(edition, limit: DEFAULT_LIMIT)
        super()
        @edition = edition
        @limit = limit
      end

      def slides
        @slides ||= ranked_results.each_with_index.filter_map do |result, index|
          selection = representative_selection(result.film_id)
          Slide.new(selection: selection, rank: index + 1, bayesian_score: result.bayesian_score) if selection
        end
      end

      def card_class_for(_slide)
        Card::FilmRank
      end

      def caption
        <<~CAPTION.strip
          #{@edition.name} #{@edition.year} — Top #{slides.size} Films by Critic Score

          #{film_lines}

          See every score: #{edition_url}
        CAPTION
      end

      private

      def film_lines
        slides.map { |slide| "#{slide.rank}. #{slide.selection.film.title}" }.join("\n")
      end

      def ranked_results
        aggregates = Rating.native.counting_towards_aggregates
          .joins(:selection)
          .where(selections: { edition_id: @edition.id })
          .group("selections.film_id")
          .pluck(Arel.sql("selections.film_id"), Arel.sql("SUM(ratings.score)"), Arel.sql("COUNT(ratings.id)"))
          .map { |film_id, sum, count| { film_id: film_id, sum: sum.to_f, count: count } }

        YearInReview::TopFilms.new(aggregates, min_ratings: @edition.min_ratings_for_summary, limit: @limit).ranked
      end

      def representative_selection(film_id)
        @edition.selections.find_by(film_id: film_id)
      end

      def edition_url
        Rails.application.routes.url_helpers.edition_url(
          @edition,
          Rails.application.config.action_mailer.default_url_options,
        )
      end
    end
  end
end
