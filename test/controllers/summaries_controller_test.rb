# frozen_string_literal: true

require "test_helper"

class SummariesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get edition_summary_url(editions(:base))
    assert_response :success
  end

  test "standalone categories are ordered by position, not average_rating" do
    get edition_summary_url(editions(:base))

    # categories(:base) has position 1 and avg_rating 3.5
    # categories(:midnight) has position 2 and avg_rating 4.5
    # Without the fix, midnight (higher avg) would come first due to SQL ordering.
    # With the fix, they must appear in position order (base before midnight).
    base_pos = response.body.index("Base Category")
    midnight_pos = response.body.index("Midnight Madness")

    assert base_pos < midnight_pos,
      "Base Category (position 1) should appear before Midnight Madness (position 2)"
  end
end
