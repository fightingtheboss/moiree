# frozen_string_literal: true

require "test_helper"

class Admin::EditionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:admin))
  end

  test "should get new" do
    festival = festivals(:base)
    get new_admin_festival_edition_url(festival)
    assert_response :success
  end

  test "should create a new Edition" do
    festival = festivals(:base)

    assert_difference("Edition.count") do
      post admin_festival_editions_url(festival), params: {
        edition: {
          code: "2024",
          year: 2024,
          start_date: "2024-01-01",
          end_date: "2024-01-10",
          url: "https://example.com",
        },
      }
    end

    assert_redirected_to admin_festival_editions_path(festival)
  end

  test "should show an Edition" do
    edition = editions(:base)
    get admin_festival_edition_url(edition.festival, edition)
    assert_response :success
  end

  test "should get edit" do
    edition = editions(:base)
    get edit_admin_festival_edition_url(edition.festival, edition)
    assert_response :success
  end

  test "should update an Edition" do
    edition = editions(:base)
    patch admin_festival_edition_url(edition.festival, edition), params: {
      edition: {
        code: "2024",
      },
    }

    assert_redirected_to admin_festival_editions_path(edition.festival)
  end

  # test "should destroy an Edition" do
  #   edition = editions(:base)

  #   assert_difference("Edition.count", -1) do
  #     delete admin_festival_edition_url(edition.festival, edition)
  #   end

  #   assert_redirected_to admin_festival_editions_path(edition.festival)
  # end
end
