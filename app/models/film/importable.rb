# frozen_string_literal: true

require "csv"

module Film::Importable
  extend ActiveSupport::Concern

  class_methods do
    def import(file, edition)
      result = ImportResult.new

      CSV.foreach(file.path, headers: true) do |row|
        # Find or create the category
        category_name = row.delete("category").last
        category = Category.find_or_initialize_by(name: category_name, edition: edition)

        # Find or create the film, associated to category
        film = where("LOWER(title) = ? AND year = ?", row["title"].downcase, row["year"]).first_or_initialize

        if film.persisted?
          import_directors = row["director"].split(",").map(&:strip).map(&:downcase)

          unless film.directors.all? { |director| import_directors.include?(director.downcase) }
            result.skipped << film
            result.errors << "#{film.title} has different directors (#{film.director}) from imported film (#{row["director"]})"
            next
          end
        end

        film.update(row.to_hash)

        film.selections.create(
          edition: edition,
          category: category,
        ) if film.editions.exclude?(edition)

        # TODO: Remove this when categorizations are removed
        film.categories << category unless film.categories.include?(category)

        if film.valid?
          result.imported << film
        else
          result.errors << film.errors.full_messages
        end
      end

      result
    end
  end
end
