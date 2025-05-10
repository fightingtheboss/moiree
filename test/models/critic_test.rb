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

  test "#attending? returns true when critic is attending an edition" do
    critic = critics(:base)
    edition = editions(:base)

    assert(critic.attending?(edition: edition))
  end

  test "#attending? returns false when critic is not attending an edition" do
    critic = critics(:base)
    non_attended_edition = festivals(:base).editions.create!(code: "TEST", year: Date.current.year, start_date: Date.current, end_date: Date.current + 7.days)

    assert_not(critic.attending?(edition: non_attended_edition))
  end

  test "#editions.current returns editions happening now" do
    critic = critics(:base)
    current_edition = festivals(:base).editions.create!(
      code: "CURRENT",
      year: Date.current.year,
      start_date: Date.current - 2.days,
      end_date: Date.current + 5.days,
    )
    critic.editions << current_edition

    assert_includes critic.editions.current, current_edition
  end

  test "#editions.past returns editions that have ended" do
    critic = critics(:base)
    past_edition = festivals(:base).editions.create!(
      code: "PAST",
      year: Date.current.year - 1,
      start_date: Date.current - 30.days,
      end_date: Date.current - 20.days,
    )
    critic.editions << past_edition

    assert_includes critic.editions.past, past_edition
  end

  test "#editions.upcoming returns editions that haven't started" do
    critic = critics(:base)
    future_edition = festivals(:base).editions.create!(
      code: "FUTURE",
      year: Date.current.year + 1,
      start_date: Date.current + 30.days,
      end_date: Date.current + 40.days,
    )
    critic.editions << future_edition

    assert_includes critic.editions.upcoming, future_edition
  end
end
