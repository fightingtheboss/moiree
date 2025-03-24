# frozen_string_literal: true

class SharesController < ApplicationController
  before_action :set_edition

  require "vips"

  def overview
    if stale?(@edition)
      respond_to do |format|
        format.svg
        format.png do
          svg = render_to_string("shares/overview", formats: :svg, layout: false, locals: { edition: @edition })

          vips_image = Vips::Image.svgload_buffer(svg, access: :sequential, dpi: 300)

          logo = ImageProcessing::Vips
            .source(Rails.root.join("app/assets/images/moiree-logo.png"))
            .resize_to_limit(160, 160)
            .call

          summary = ImageProcessing::Vips
            .source(vips_image)
            .resize_to_fill(1100, 530)
            .loader(page: 0, density: 300) # Adjust density for higher resolution
            .convert("png")
            .call

          image = ImageProcessing::Vips
            .source(Rails.root.join("app/assets/images/moiree-bg-sm.png"))
            .resize_to_fill(1200, 630)
            .composite(summary, gravity: "north-west", offset: [50, 50])
            .composite(logo, gravity: "north-west", offset: [900, 100])
            .convert("png")
            .call

          send_data(File.read(image.path), type: "image/png", disposition: "inline")
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
