# frozen_string_literal: true

module Film::Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search(query, edition_id: nil, exclude: false, blank_returns_none: false)
      films = blank_returns_none ? none : all

      if query.present?
        films = where("films.title LIKE :query OR films.normalized_title LIKE :query", query: "%#{query}%")
      end

      if edition_id.present?
        films = films.joins(selections: :edition)

        films = if exclude
          edition = Edition.friendly.find(edition_id)
          films.where.not(id: edition.films)
        else
          films.where(edition: { id: edition_id })
        end
      end

      films.order(title: :asc).uniq
    end

    def search_within_edition(query, edition_id)
      search(query, edition_id: edition_id)
    end

    def search_excluding_edition(query, edition_id)
      search(query, edition_id: edition_id, exclude: true, blank_returns_none: true)
    end
  end
end
