# frozen_string_literal: true

class EditionsController < ApplicationController
  # skip_before_action :authenticate

  layout "application"

  def show
    hidden_critics = params[:critics]

    @edition = Edition.find(params[:id])
    @selections = @edition.selections_with_categories.includes(ratings: :critic).order("films.title")
    @selections_by_category = @selections.group_by do |selection|
                                selection.film.categories.first
                              end.sort_by { |category, _selections| category&.name }
    @critics = @selections.map(&:ratings).flatten.compact.map(&:critic).uniq.sort_by(&:last_name).reject do |critic|
      hidden_critics&.include?(critic.id.to_s)
    end
    @ratings = @critics.each_with_object({}) do |critic, selection_hash|
      selection_hash[critic] = @selections.each_with_object({}) do |selection, rating_hash|
        rating_hash[selection] = selection.ratings.find { |rating| rating.critic == critic }
      end
    end
  end
end
