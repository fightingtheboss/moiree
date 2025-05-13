# frozen_string_literal: true

class RatingsController < ApplicationController
  def show
    @rating = Rating.find(params[:id])
  end
end
