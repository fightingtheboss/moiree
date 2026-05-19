# frozen_string_literal: true

require "test_helper"

class EditionsHelperTest < ActionView::TestCase
  # --- format_rating ---

  test "#format_rating returns the walked-out indicator for a walked-out rating" do
    rating = ratings(:base).tap { |r| r.walked_out = true }
    result = format_rating(rating)

    assert_includes(result, "🚪🚶")
    assert_includes(result, "tracking-[-0.2rem]")
    assert_includes(result, "whitespace-nowrap")
  end

  test "#format_rating ignores score when walked out" do
    rating = ratings(:base).tap { |r| r.walked_out = true }
    result = format_rating(rating)

    assert_not_includes(result.to_s, "🔥")
  end

  test "#format_rating returns bomb emoji for zero score" do
    rating = ratings(:base).tap { |r| r.score = 0 }
    assert_equal("💣", format_rating(rating))
  end

  test "#format_rating returns fire emoji for 5.0 score" do
    rating = ratings(:base).tap { |r| r.score = 5.0 }
    assert_equal("🔥", format_rating(rating))
  end

  test "#format_rating returns score for values between 0 and 5" do
    rating = ratings(:base)
    assert_equal(rating.score, format_rating(rating))
  end

  # --- display_score ---

  test "#display_score returns bomb emoji for zero" do
    assert_equal("💣", display_score(0.0))
  end

  test "#display_score returns fire emoji for 5.0" do
    assert_equal("🔥", display_score(5.0))
  end

  test "#display_score returns score for other values" do
    assert_equal(3.5, display_score(3.5))
  end

  # --- walked_out_indicator ---

  test "#walked_out_indicator returns a span with the walked-out emoji and styling classes" do
    result = walked_out_indicator

    assert_includes(result, "🚪🚶")
    assert_includes(result, "tracking-[-0.2rem]")
    assert_includes(result, "whitespace-nowrap")
  end
end
