# frozen_string_literal: true

require "test_helper"

class YearsControllerTest < ActionDispatch::IntegrationTest
  test "should get show for year with editions" do
    get year_url(2024)
    assert_response :success
  end

  test "should return 404 for year without editions" do
    get year_url(2099)
    assert_response :not_found
  end
end
