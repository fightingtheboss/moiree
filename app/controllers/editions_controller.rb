# frozen_string_literal: true

class EditionsController < ApplicationController
  skip_before_action :authenticate

  layout "application"

  def show
    @edition = Edition.find(params[:id])
    @selections = @edition.selections.includes(:film, ratings: :critic)
    @critics = @selections.map(&:ratings).flatten.compact.map(&:critic).uniq.sort_by(&:last_name)
    @ratings = @critics.each_with_object({}) do |critic, selection_hash|
      selection_hash[critic] = @selections.each_with_object({}) do |selection, rating_hash|
        rating_hash[selection] = selection.ratings.find { |rating| rating.critic == critic }
      end
    end
  end
end
