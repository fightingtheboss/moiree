# frozen_string_literal: true

class EditionsController < ApplicationController
  # skip_before_action :authenticate

  layout "application"

  def show
    hidden_critics = params[:critics]

    @edition = Edition.friendly.find(params[:id])
    @selections = @edition.selections.includes(:category, :film, ratings: :critic).order("films.title")

    if only_show_rated?
      @selections = @selections.where.associated(:ratings)
    end

    @selections_by_category = @selections.group_by(&:category).sort_by { |category, _selections| category&.position }

    @critics = @edition.critics.sort_by(&:last_name).reject do |critic|
      hidden_critics&.include?(critic.id.to_s)
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
