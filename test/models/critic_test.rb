require "test_helper"

class CriticTest < ActiveSupport::TestCase
  test "#name returns first and last name" do
    critic = critics(:base)

    assert(critic.name == "Daniel Kasman")
  end

  test "#initials returns first letter of first and last name" do
    critic = critics(:base)

    assert(critic.initials == "DK")
  end
end
