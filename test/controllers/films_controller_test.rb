# frozen_string_literal: true

require "test_helper"

class FilmsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get film_url(films(:base))
    assert_response :success
  end
end
