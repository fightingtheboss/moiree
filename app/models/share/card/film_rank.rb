# frozen_string_literal: true

module Share
  module Card
    class FilmRank < Base
      private

      def draw(canvas, width:, height:)
        selection = data.selection
        film = selection.film

        canvas = draw_text(canvas, "##{data.rank}", x: 60, y: 60, font: "Sans Bold 96")
        canvas = draw_text(canvas, film.title.upcase, x: 60, y: height - 220, font: "Sans Bold 48")
        canvas = draw_text(canvas, film.directors.first, x: 60, y: height - 150, font: "Sans 32", color: [90, 90, 90])
        draw_text(canvas, format("%.2f", data.bayesian_score), x: 60, y: height - 90, font: "Sans Bold 40")
      end
    end
  end
end
