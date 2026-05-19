# frozen_string_literal: true

require "test_helper"

class EditionsHelperTest < ActionView::TestCase
  test "#display_rating returns a span with the walked-out emoji for walked_out: true" do
    result = display_rating(0, walked_out: true)

    assert_includes(result, "🚪🚶")
    assert_includes(result, "tracking-[-0.2rem]")
    assert_includes(result, "whitespace-nowrap")
  end

  test "#display_rating ignores score when walked_out: true" do
    result = display_rating(5.0, walked_out: true)

    assert_includes(result, "🚪🚶")
    assert_not_includes(result, "🔥")
  end

  test "#display_rating returns bomb emoji for zero score" do
    assert_equal("💣", display_rating(0.0))
  end

  test "#display_rating returns fire emoji for 5.0 score" do
    assert_equal("🔥", display_rating(5.0))
  end

  test "#display_rating returns score for values between 0 and 5" do
    assert_equal(3.5, display_rating(3.5))
  end
end
