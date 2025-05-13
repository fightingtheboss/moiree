# frozen_string_literal: true

require "test_helper"

class RatingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rating = ratings(:base)
  end

  test "should get show" do
    get rating_path(@rating)
    assert_response :success
  end

  test "should return 404 for non-existent rating" do
    get rating_path(999999)
    assert_response :not_found
  end
end
