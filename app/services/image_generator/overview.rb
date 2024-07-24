# frozen_string_literal: true

module ImageGenerator
  class Overview
    include Vips

    def initialize(edition)
      @edition = edition
    end

    def generate
      # Create a blank canvas
      image = Image.black(1200, 630).invert

      # Add background image
      bg_image = Image.new_from_file(Rails.root.join("app/assets/images/moiree-bg-sm.png").to_s)
      image = image.composite(bg_image, :over, x: 0, y: 0)

      # Add white rectangle background
      white_rect = Image.black(1100, 530).invert
      image = image.composite(white_rect, :over, x: 50, y: 50)

      # Add text
      image = add_text(image, @edition.name.upcase, 100, 120, 24)
      image = add_text(image, @edition.code, 100, 170, 48, bold: true)
      date_text = "#{@edition.start_date.strftime("%b %d, %Y")} — #{@edition.end_date.strftime("%b %d, %Y")}"
      image = add_text(image, date_text, 100, 210, 24)
      image = add_text(image, Rails.application.routes.url_helpers.edition_url(@edition), 100, 250, 24)

      # Add logo
      logo_image = Image.new_from_file(Rails.root.join("app/assets/images/moiree-logo.png").to_s) # Convert SVG to PNG or use a PNG logo
      image = image.composite(logo_image, :over, x: 950, y: 92)

      # Add statistics boxes and text
      image = add_statistics_boxes(image)

      # Return the generated image as a blob
      image.pngsave_buffer
    end

    private

    def add_text(image, text, x, y, size, bold: false)
      font = bold ? "Inter-Bold" : "Inter-Regular"
      text_image = Vips::Image.text(text, dpi: 300, font: "#{font} #{size}")
      image.composite(text_image, :over, x: x, y: y)
    end

    def add_statistics_boxes(image)
      4.times do |i|
        image = add_box(image, 82 + (i * (247 + 16)), 308)
      end

      [
        ["CATEGORIES", @edition.categories.size],
        ["FILMS", @edition.selections.size],
        ["CRITICS", @edition.critics.size],
        ["RATINGS", @edition.ratings.size],
      ].each_with_index do |(label, count), i|
        x_pos = 205 + (i * (247 + 16))
        image = add_statistics_text(image, x_pos, 360, label, count)
      end

      image
    end

    def add_box(image, x, y)
      box = Image.black(247, 192).invert
      image.composite(box, :over, x: x, y: y)
    end

    def add_statistics_text(image, x, y, label, value)
      image = add_text(image, label, x, y, 32, bold: true)
      image = add_text(image, value.to_s, x, y + 100, 92, bold: true)
      image
    end
  end
end
