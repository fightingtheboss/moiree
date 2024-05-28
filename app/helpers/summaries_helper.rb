# frozen_string_literal: true

module SummariesHelper
  def histogram_height(total, max)
    percentage = (total.to_f / max * 100).to_i
    "calc(#{percentage}% + 1px)"
  end

  def histogram_title(score, count)
    "#{count} #{histogram_stars(score)} #{"rating".pluralize(count)}"
  end

  def histogram_stars(score)
    if score == 0
      "💣"
    elsif score == 5.0
      "🔥"
    else
      "⭐️" * score.abs + (score - score.truncate == 0.5 ? "½" : "")
    end
  end
end
