# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["CAPYBARA_SERVER_PORT"]
    served_by host: "moiree", port: ENV["CAPYBARA_SERVER_PORT"]

    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400], options: {
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444",
    }
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end

  def sign_in_as(user)
    visit(sign_in_url)
    fill_in(:email, with: user.email)
    fill_in(:password, with: "Secret1*3*5*")
    click_on("Sign in")

    assert_current_path(root_url)
    user
  end
end
