# frozen_string_literal: true

module EditionsHelper
  def display_rating(score)
    if score.zero?
      "💣"
    elsif score == 5.0
      "🔥"
    else
      score
    end
  end

  def params_cache_key
    Digest::MD5.hexdigest(
      params.to_unsafe_h.except(:controller, :action, :format, :locale).to_s,
    )
  end
end
