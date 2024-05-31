# frozen_string_literal: true

class SharesController < ApplicationController
  before_action :set_edition

  def overview
  end

  def summary
  end

  def stat
  end

  private

  def set_edition
    @edition = Edition.includes(:festival, :critics, :ratings, :selections).friendly.find(params[:edition_id])
  end
end
