# frozen_string_literal: true

class FilmsController < ApplicationController
  def show
    @film = Film.includes(:editions, ratings: :critic).friendly.find(params[:id])
  end
end
