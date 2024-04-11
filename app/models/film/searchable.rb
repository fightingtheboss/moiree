# frozen_string_literal: true

module Film::Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search(query, edition_id: nil, exclude: false)
      films = all

      if query.present?
        films = where("films.title LIKE :query", query: "%#{query}%")
      end

      if edition_id.present?
        films = films.joins(selections: :edition)

        films = if exclude
          edition = Edition.find(edition_id)
          films.where.not(id: edition.films)
        else
          films.where(edition: { id: edition_id })
        end
      end

      films.distinct
    end

    def search_within_edition(query, edition_id)
      search(query, edition_id: edition_id)
    end

    def search_excluding_edition(query, edition_id)
      search(query, edition_id: edition_id, exclude: true)
    end
  end
end
