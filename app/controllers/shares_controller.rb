# frozen_string_literal: true

class SharesController < ApplicationController
  before_action :set_edition

  def overview
    if stale?(@edition)
      respond_to do |format|
        format.svg
        format.png do
          if @edition.share_image.attached?
            send_data(
              @edition.share_image.download,
              type: "image/png",
              disposition: "inline",
            )
          else
            head(:not_found)
          end
        end
      end
    end
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
