# frozen_string_literal: true

require "test_helper"

class Admin
  class AdminControllerTest < ActionDispatch::IntegrationTest
    test "should redirect to sign in if not an admin" do
      sign_in_as(users(:critic))

      get new_admin_invitation_url
      assert_redirected_to sign_in_url
    end

    test "should redirect to sign in if not signed in" do
      get new_admin_invitation_url
      assert_redirected_to sign_in_url
    end

    test "should sign in successfully if an admin" do
      sign_in_as(users(:admin))

      get new_admin_invitation_url
      assert_response :success
    end
  end
end
