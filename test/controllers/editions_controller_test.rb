# frozen_string_literal: true

require "test_helper"

class EditionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get edition_url(editions(:base))
    assert_response :success
  end
end
