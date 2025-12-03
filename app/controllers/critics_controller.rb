# frozen_string_literal: true

class CriticsController < ApplicationController
  def index
    @critics = Critic.includes(:ratings).joins(:ratings).distinct.order(:first_name, :last_name)
  end

  def show
    @critic = Critic.includes(ratings: [:film, :edition]).friendly.find(params[:id])
    @editions = @critic.editions.order("start_date DESC").uniq
    @ratings = @critic.ratings.includes(:film, selection: :category).order("films.title")
  end
end
