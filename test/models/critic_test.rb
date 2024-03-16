# frozen_string_literal: true

require "test_helper"

class CriticTest < ActiveSupport::TestCase
  test "should not be valid if country code is invalid" do
    critic = critics(:base)
    critic.country = "INVALID"

    assert_not(critic.valid?)
    assert(critic.errors.full_messages.first.include?("is not included in the list"))
  end

  test "should not be valid if required fields are not present" do
    critic = Critic.new

    assert_not(critic.valid?)
  end

  test "#name returns first and last name" do
    critic = critics(:base)

    assert(critic.name == "Daniel Kasman")
  end

  test "#initials returns first letter of first and last name" do
    critic = critics(:base)

    assert(critic.initials == "DK")
  end

  test "#films returns the Films rated by the Critic" do
    critic = critics(:base)
    film = films(:base)

    assert(critic.films.include?(film))
  end
end
