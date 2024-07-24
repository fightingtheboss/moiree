# frozen_string_literal: true

class SharesController < ApplicationController
  before_action :set_edition

  def overview
    respond_to do |format|
      format.svg
      format.png do
        svg = render_to_string("shares/overview", formats: :svg, layout: false, locals: { edition: @edition })

        # Convert SVG to PNG using ImageProcessing with MiniMagick backend
        vips_image = ImageProcessing::MiniMagick
          .source(svg)
          .loader(page: 0, density: 300) # Adjust density for higher resolution
          .convert("png")
          .call

        send_data(vips_image.to_blob, type: "image/png", disposition: "inline")
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
