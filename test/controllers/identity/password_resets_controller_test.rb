# frozen_string_literal: true

require "test_helper"

class Identity::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin)
  end

  test "should get new" do
    get new_identity_password_reset_url
    assert_response :success
  end

  test "should get edit" do
    sid = @user.generate_token_for(:password_reset)

    get edit_identity_password_reset_url(sid: sid)
    assert_response :success
  end

  test "should send a password reset email" do
    assert_enqueued_email_with UserMailer, :password_reset, params: { user: @user } do
      post identity_password_reset_url, params: { email: @user.email }
    end

    assert_redirected_to root_url
    assert_equal "If an account exists for that email, we've sent password reset instructions", flash[:notice]
  end

  test "should send a password reset email to an unverified user" do
    @user.update!(verified: false)

    assert_enqueued_email_with UserMailer, :password_reset, params: { user: @user } do
      post identity_password_reset_url, params: { email: @user.email }
    end

    assert_redirected_to root_url
  end

  test "should respond the same way to a nonexistent email without sending an email" do
    assert_no_enqueued_emails do
      post identity_password_reset_url, params: { email: "invalid_email@hey.com" }
    end

    assert_redirected_to root_url
    assert_equal "If an account exists for that email, we've sent password reset instructions", flash[:notice]
  end

  test "should update password" do
    sid = @user.generate_token_for(:password_reset)

    patch identity_password_reset_url,
      params: { sid: sid, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }
    assert_redirected_to sign_in_url
  end

  test "should verify an unverified user when they reset their password" do
    @user.update!(verified: false)
    sid = @user.generate_token_for(:password_reset)

    patch identity_password_reset_url,
      params: { sid: sid, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }

    assert @user.reload.verified?
  end

  test "should not update password with expired token" do
    sid = @user.generate_token_for(:password_reset)

    travel 30.minutes

    patch identity_password_reset_url,
      params: { sid: sid, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }

    assert_redirected_to new_identity_password_reset_url
    assert_equal "That password reset link is invalid", flash[:alert]
  end
end
