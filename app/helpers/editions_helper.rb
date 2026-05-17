# frozen_string_literal: true

module EditionsHelper
  def display_rating(score, walked_out: false)
    if walked_out
      "🚪🚶"
    elsif score.zero?
      "💣"
    elsif score == 5.0
      "🔥"
    else
      score
    end
  end
end
