# frozen_string_literal: true

require "test_helper"

class EditionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get edition_url(editions(:base))
    assert_response :success
  end

  test "show sets public cache control for HTTP caching" do
    get edition_url(editions(:base))
    assert_response :success
    assert response.headers["Cache-Control"].include?("public")
  end

  test "show returns 304 when edition has not changed" do
    edition = editions(:base)
    get edition_url(edition)
    assert_response :success

    get edition_url(edition), headers: { "If-None-Match" => response.etag }
    assert_response :not_modified
  end
end
