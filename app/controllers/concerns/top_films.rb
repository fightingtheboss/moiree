# frozen_string_literal: true

module TopFilms
  extend ActiveSupport::Concern

  private

  def top_films_of_year(year)
    edition_ids = Edition.within(year).pluck(:id)

    return [] if edition_ids.empty?

    # Get the best selection per film (highest average_rating)
    best_selection_ids = Selection.joins(:ratings)
      .where(edition_id: edition_ids)
      # .where.not(ratings: { impression: [nil, ""] })
      .group("selections.id")
      .having("COUNT(ratings.id) >= 2")
      .select("selections.id, selections.film_id, selections.average_rating")
      .then do |selections|
        # Group by film_id and keep only the one with highest average_rating
        selections.group_by(&:film_id).map { |_, sels| sels.max_by(&:average_rating).id }
      end

    Selection.where(id: best_selection_ids)
      .order(average_rating: :desc)
      .limit(5)
      .includes(:film, ratings: :critic)
  end
end
