# frozen_string_literal: true

class SvgsController < ApplicationController
  def show
    @edition = Edition.includes(:festival, :critics, :ratings, :selections).friendly.find(params[:edition_id])
  end
end
