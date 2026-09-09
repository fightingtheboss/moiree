# frozen_string_literal: true

module Share
  module Card
    class Base
      def initialize(data)
        @data = data
      end

      def build(width:, height:)
        draw(blank_canvas(width, height), width: width, height: height).flatten(background: [255, 255, 255])
      end

      private

      attr_reader :data

      def draw(canvas, width:, height:)
        raise NotImplementedError, "#{self.class} must implement #draw"
      end

      def blank_canvas(width, height, background: [255, 255, 255])
        solid_color(width, height, background)
      end

      def draw_text(image, text, x:, y:, font:, color: [0, 0, 0])
        mask = Vips::Image.text(text, font: font)
        layer = solid_color(mask.width, mask.height, color).bandjoin(mask)
        image.composite2(layer, :over, x: x, y: y)
      end

      # composite2 blends via colourspace conversion, so both operands need a
      # known interpretation (srgb) — a plain `Vips::Image.black(...) + color`
      # stays generic "multiband" and composite2 raises
      # "no known route from 'multiband' to 'srgb'". Verified directly against
      # the installed ruby-vips 2.3.0 with `bin/rails runner`.
      def solid_color(width, height, color)
        (Vips::Image.black(width, height, bands: 3) + color).cast("uchar").copy(interpretation: :srgb)
      end
    end
  end
end
