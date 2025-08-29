# frozen_string_literal: true

class GenerateEditionShareImageJob < ApplicationJob
  queue_as :default

  def perform(edition_id = :all)
    if edition_id == :all
      # Only enqueue jobs for current editions
      Edition.current.find_each { |edition| self.class.perform_later(edition.id) }
      return
    end

    edition = Edition.find(edition_id)
    svg = ApplicationController.render(
      template: "shares/overview",
      formats: [:svg],
      assigns: { edition: edition },
      layout: false,
    )

    # intermediate and external assets
    logo = ImageProcessing::Vips
      .source(Rails.root.join("app/assets/images/moiree-logo-160.png"))
      .call(save: false)

    summary = ImageProcessing::Vips
      .source(Vips::Image.svgload_buffer(svg, access: :sequential, dpi: 300))
      .resize_to_fill(1100, 530)
      .loader(page: 0, density: 300)
      .convert("png")
      .call(save: false)

    final_image = nil

    begin
      final_image = ImageProcessing::Vips
        .source(Rails.root.join("app/assets/images/moiree-bg-sm.png"))
        .resize_to_fill(1200, 630)
        .composite(summary, gravity: "north-west", offset: [50, 50])
        .composite(logo, gravity: "north-west", offset: [900, 100])
        .convert("png")
        .call

      # Attach using a block so file descriptor is closed immediately after attach
      File.open(final_image.path) do |f|
        edition.share_image.attach(
          io: f,
          filename: "share.png",
          content_type: "image/png",
        )
      end
    ensure
      # Explicitly try to close/unlink temporary objects where supported.
      cleanup_temp(summary)
      cleanup_temp(logo)
      cleanup_temp(final_image)
    end
  end

  private

  # Attempt to close and remove temp-like objects returned by ImageProcessing or Vips.
  def cleanup_temp(obj)
    return unless obj

    # Tempfile-like close
    if obj.respond_to?(:close!)
      obj.close!
    elsif obj.respond_to?(:close)
      obj.close
    end

    # Ensure file is removed if still present and we have a path
    if obj.respond_to?(:path) && obj.path && File.exist?(obj.path)
      begin
        File.delete(obj.path)
      rescue => e
        Rails.logger.debug("Failed to delete temp file #{obj.path}: #{e.message}")
      end
    end
  rescue => e
    Rails.logger.debug("cleanup_temp error: #{e.message}")
  end
end
