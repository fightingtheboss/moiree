# frozen_string_literal: true

require "test_helper"

class Admin
  class InvitationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = sign_in_as(users(:admin))
    end

    test "should get new" do
      get new_admin_invitation_url
      assert_response :success
    end

    test "should create a new Admin user" do
      assert_difference("Admin.count") do
        post admin_invitation_url, params: { user: { email: "new.user@moire.reviews" } }
      end

      assert_redirected_to new_admin_invitation_url
    end

    test "should send invitation instructions email to new admin" do
      assert_enqueued_email_with UserMailer, :invitation_instructions, params: { user: @admin } do
        post admin_invitation_url, params: { user: { email: @admin.email } }
      end

      assert_redirected_to new_admin_invitation_url
    end
  end
end
