# frozen_string_literal: true

class FallbackEditionShareImageJob < ApplicationJob
  queue_as :default

  def perform(edition_id)
    edition = Edition.find(edition_id)

    svg = ApplicationController.render(
      template: "shares/fallback",
      formats: [:svg],
      assigns: { edition: edition },
      layout: false,
    )

    logo = ImageProcessing::Vips
      .source(Rails.root.join("app/assets/images/moiree-logo-160.png"))
      .call(save: false)

    fallback = ImageProcessing::Vips
      .source(Vips::Image.svgload_buffer(svg, access: :sequential, dpi: 300))
      .resize_to_fill(1100, 530)
      .convert("png")
      .call(save: false)

    image = ImageProcessing::Vips
      .source(Rails.root.join("app/assets/images/moiree-bg-sm.png"))
      .resize_to_fill(1200, 630)
      .composite(fallback, gravity: "north-west", offset: [50, 50])
      .composite(logo, gravity: "north-west", offset: [900, 100])
      .convert("png")
      .call

    edition.share_image.attach(
      io: File.open(image.path),
      filename: "share-fallback.png",
      content_type: "image/png",
    )
  end
end
