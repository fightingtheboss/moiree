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

      # fontfile: points Pango straight at a vendored font file (see Share::Card::FilmRank's
      # REGULAR_FONT_FILE/BOLD_FONT_FILE) instead of relying on whatever's registered with
      # fontconfig on the host — works identically in dev, test, and production, with no
      # Docker/fontconfig setup required. Left nil, text falls back to the system's default
      # "Sans" alias.
      def draw_text(image, text, x:, y:, font:, fontfile: nil, color: [0, 0, 0])
        mask = Vips::Image.text(CGI.escapeHTML(text), font: font, fontfile: fontfile)
        layer = solid_color(mask.width, mask.height, color).bandjoin(mask)
        image.composite2(layer, :over, x: x, y: y)
      end

      # Pango markup has no ellipsize option in the installed libvips, so truncation is
      # done client-side by measuring rendered width and trimming until it fits.
      #
      # Takes and returns raw (unescaped) text — callers pass the result straight into
      # #draw_text, which does the Pango escaping. Width is measured on the escaped form
      # (matching what #draw_text will eventually render), which is slightly conservative
      # since e.g. "&amp;" measures wider than the "&" glyph it renders as — fine for a
      # truncation bound, and avoids double-escaping.
      def truncate_to_fit(text, font:, max_width:, fontfile: nil)
        return text if Vips::Image.text(CGI.escapeHTML(text), font: font, fontfile: fontfile).width <= max_width

        truncated = text.dup
        loop do
          truncated = truncated[0..-2]
          candidate = "#{truncated}…"
          width = Vips::Image.text(CGI.escapeHTML(candidate), font: font, fontfile: fontfile).width
          return candidate if width <= max_width || truncated.empty?
        end
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
