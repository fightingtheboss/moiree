# frozen_string_literal: true

require "test_helper"

module Sessions
  class PasswordlessesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:critic)
      @unverified_user = users(:unverified_user)
      @token = SignInToken.create!(user: @user)
      @signed_id = CGI.escape(@token.signed_id)
    end

    test "should get new" do
      get new_sessions_passwordless_path
      assert_response :success
      assert_select "form[action='#{magic_path}']"
    end

    test "edit action when litefs primary exists" do
      # Stub the helper method directly
      Sessions::PasswordlessesController.any_instance.stubs(:litefs_primary_instance_id).returns("instance-123")

      get edit_sessions_passwordless_path(sid: @signed_id)

      assert_response :ok
      assert_equal "instance=instance-123", response.headers["fly-replay"]
    end

    test "edit action when litefs primary does not exist" do
      # Stub the helper method to return nil
      Sessions::PasswordlessesController.any_instance.stubs(:litefs_primary_instance_id).returns(nil)

      assert_difference -> { @user.sessions.count }, 1 do
        get edit_sessions_passwordless_path(sid: @signed_id)
      end

      # Verify session token was set in cookies
      assert_not_nil cookies[:session_id]

      # Verify tokens were revoked
      assert_equal 0, @user.sign_in_tokens.count

      # Verify redirect
      assert_redirected_to admin_root_path
      assert_equal "Signed in successfully", flash[:notice]
    end

    test "create action with verified user" do
      assert_emails 1 do
        post sessions_passwordless_path, params: { email: @user.email }
      end

      assert_redirected_to root_path
      assert_equal "Check your email for sign in instructions", flash[:notice]
    end

    test "create action with unverified user" do
      post sessions_passwordless_path, params: { email: @unverified_user.email }

      assert_redirected_to magic_path
      assert_equal "You can't sign in until you verify your email", flash[:alert]
    end

    test "create action with non-existent user" do
      post sessions_passwordless_path, params: { email: "nonexistent@example.com" }

      assert_redirected_to magic_path
      assert_equal "You can't sign in until you verify your email", flash[:alert]
    end

    test "set_user with invalid token" do
      get edit_sessions_passwordless_path(sid: "invalid-token")

      assert_redirected_to new_sessions_passwordless_path
      assert_equal "That sign in link is invalid", flash[:alert]
    end

    test "revoke_tokens removes all sign in tokens" do
      # Create additional tokens for the user
      SignInToken.create!(user: @user)
      SignInToken.create!(user: @user)

      assert_difference -> { @user.sign_in_tokens.count }, -3 do
        # Stub the helper method to return nil
        Sessions::PasswordlessesController.any_instance.stubs(:litefs_primary_instance_id).returns(nil)
        get edit_sessions_passwordless_path(sid: @signed_id)
      end
    end
  end
end
