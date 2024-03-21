require "test_helper"

class Admin::FilmsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_films_new_url
    assert_response :success
  end
end
