# frozen_string_literal: true

module EditionsHelper
  def format_rating(rating)
    if rating.walked_out?
      walked_out_indicator
    elsif rating.score.zero?
      "💣"
    elsif rating.score == 5.0
      "🔥"
    else
      rating.score
    end
  end

  def display_score(score)
    if score.zero?
      "💣"
    elsif score == 5.0
      "🔥"
    else
      score
    end
  end

  def walked_out_indicator
    content_tag(:span, "🚪🚶", class: "tracking-[-0.2rem] whitespace-nowrap")
  end
end
