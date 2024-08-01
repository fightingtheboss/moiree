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

  test "#publication_for returns the Critic's base publication when no Attendance override set" do
    critic = critics(:base)
    edition = editions(:base)

    assert(critic.publication_for(edition: edition) == critic.publication)
  end

  test "#publication_for returns the Critic's Attendance publication when set" do
    critic = critics(:base)
    edition = editions(:base)
    attendance = attendances(:base)

    attendance.update!(publication: "Override")

    assert(critic.publication_for(edition: edition) == "Override")
  end

  test "#has_custom_publication? returns true when the Critic's publication is different from the Attendance publication" do
    critic = critics(:base)
    edition = editions(:base)
    attendance = attendances(:base)

    attendance.update!(publication: "Override")

    assert(critic.has_custom_publication?(edition: edition))
  end

  test "#has_custom_publication? returns false when the Critic's publication is the same as the Attendance publication" do
    critic = critics(:base)
    edition = editions(:base)

    assert_not(critic.has_custom_publication?(edition: edition))
  end
end
