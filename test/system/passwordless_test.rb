# frozen_string_literal: true

require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  setup do
    @user = users(:critic)
  end

  test "signing in with a passwordless email" do
    visit magic_url

    fill_in "Email", with: @user.email
    click_on "Send me the sign-in link"

    assert_text "Check your email for sign in instructions"

    # Simulate email delivery and extract the login link
    email = ActionMailer::Base.deliveries.last
    assert_not_nil(email)

    login_link = email.html_part.body.to_s.match(/href="(?<url>.+?)">/)[:url]
    sid = URI.parse(login_link).query.match(/sid=(?<sid>.+)/)[:sid]

    visit(verify_path(sid: sid))

    assert_text "Signed in successfully"
  end
end
