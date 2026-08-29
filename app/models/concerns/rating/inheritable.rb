# frozen_string_literal: true

module Rating::Inheritable
  extend ActiveSupport::Concern

  included do
    belongs_to :source_edition, class_name: "Edition", optional: true
    scope :native, -> { where(source_edition_id: nil) }
  end

  class_methods do
    def inherit_for(critic:, selection:)
      return if exists?(critic:, selection:)
      return unless (source = prior_native_for(critic:, film_id: selection.film_id))

      create!(
        critic:,
        selection:,
        score: source.score,
        review_url: source.review_url,
        impression: source.impression,
        source_edition_id: source.source_edition_id || source.selection.edition_id,
        skip_cache_average_ratings_callback: true,
      )
    end

    private

    def prior_native_for(critic:, film_id:)
      native
        .joins(selection: :edition)
        .where(critic:, selections: { film_id: })
        .order("editions.end_date DESC")
        .first
    end
  end
end
