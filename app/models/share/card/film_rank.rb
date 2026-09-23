# frozen_string_literal: true

module Share
  module Card
    class FilmRank < Base
      REGULAR_FONT_FILE = Rails.root.join("app/assets/fonts/inter/Inter-Regular.ttf").to_s
      BOLD_FONT_FILE = Rails.root.join("app/assets/fonts/inter/Inter-Bold.ttf").to_s
      TITLE_FONT = "Inter Bold 48"

      private

      def draw(canvas, width:, height:)
        selection = data.selection
        film = selection.film
        title = truncate_to_fit(film.title.upcase, font: TITLE_FONT, max_width: width - 120, fontfile: BOLD_FONT_FILE)

        canvas = draw_text(canvas, "##{data.rank}", x: 60, y: 60, font: "Inter Bold 96", fontfile: BOLD_FONT_FILE)
        canvas = draw_text(canvas, title, x: 60, y: height - 220, font: TITLE_FONT, fontfile: BOLD_FONT_FILE)
        canvas = draw_text(
          canvas,
          film.directors.first,
          x: 60,
          y: height - 150,
          font: "Inter 32",
          fontfile: REGULAR_FONT_FILE,
          color: [90, 90, 90],
        )
        draw_text(
          canvas,
          format("%.2f", data.bayesian_score),
          x: 60,
          y: height - 90,
          font: "Inter Bold 40",
          fontfile: BOLD_FONT_FILE,
        )
      end
    end
  end
end
