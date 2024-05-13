# frozen_string_literal: true

require "test_helper"

class Admin::CriticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:admin))
    @critic = critics(:base)
  end

  test "should get edit" do
    get edit_admin_critic_url(@critic)
    assert_response :success
  end

  test "should update successfully" do
    patch admin_critic_url(@critic), params: {
      user: {
        id: @critic.user.id,
        userable_type: "Critic",
        userable_attributes: {
          id: @critic.id,
          first_name: "Updated",
          last_name: "User",
          publication: "Moirée Reviews",
          country: "CA",
        },
      },
    }

    @critic.reload

    assert_equal "Updated", @critic.first_name
    assert_equal "User", @critic.last_name
    assert_equal "CA", @critic.country

    assert_redirected_to critics_admin_users_url
  end
end
