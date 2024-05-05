# frozen_string_literal: true

require "test_helper"

class CriticsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get critic_url(critics(:base))
    assert_response :success
  end
end
