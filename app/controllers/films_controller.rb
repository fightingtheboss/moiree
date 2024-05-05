# frozen_string_literal: true

class FilmsController < ApplicationController
  def show
    @film = Film.includes(:editions, ratings: :critic).find(params[:id])
  end
end
