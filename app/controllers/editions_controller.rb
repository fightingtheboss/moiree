# frozen_string_literal: true

class EditionsController < ApplicationController
  layout "application"

  def show
    hidden_critics = params[:critics]

    @edition = edition = Edition.friendly.find(params[:id])
    @selections = @edition.selections.includes(:category, :film, ratings: :critic).order("films.title")

    if only_show_rated?
      @selections = @selections.where.associated(:ratings)
    end

    @selections_by_category = @selections.group_by(&:category).sort_by { |category, _selections| category&.position }
    @film_directors = @selections.map(&:film).uniq.index_with { |film| film.directors.join(", ") }

    @critics = @edition.critics
      .includes(:attendances)
      .order(last_name: :asc)
      .reject { |critic| hidden_critics&.include?(critic.id.to_s) }
      .each do |critic|
        # Set the publication for the critic based on their attendance at the edition
        # Do this dynamically to avoid N+1 queries
        critic.define_singleton_method(:publication) do
          attendances.find { |attendance| attendance.edition_id == edition.id }&.publication || super()
        end

        # TODO: Can just persist this in the database
        critic.define_singleton_method(:country_emoji) { Country[country].emoji_flag }
      end

    @ratings = @critics.each_with_object({}) do |critic, selection_hash|
      selection_hash[critic] = @selections.each_with_object({}) do |selection, rating_hash|
        rating_hash[selection] = selection.ratings.find { |rating| rating.critic == critic }
      end
    end
  end

  def live
    @edition = Edition.friendly.find(params[:id])
    @ratings = @edition.ratings.includes(
      :critic,
      :film,
    ).where(critic: @edition.critics).order(created_at: :desc)
  end

  private

  def only_show_rated?
    params[:saf] == "false" || (params[:saf].nil? && @edition.current? && @edition.ratings.any?)
  end
end
