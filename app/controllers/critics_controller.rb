# frozen_string_literal: true

class CriticsController < ApplicationController
  def show
    @critic = Critic.includes(ratings: [:film, :edition]).friendly.find(params[:id])
    @editions = @critic.editions.order("start_date DESC").uniq
    @ratings = @critic.ratings.includes(:film).order("films.title")
  end
end
