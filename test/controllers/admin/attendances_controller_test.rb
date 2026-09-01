# frozen_string_literal: true

require "test_helper"

class Admin::AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:admin))
  end

  test "create renders the critic partial via turbo_stream without raising" do
    edition = editions(:with_no_films)
    critic = critics(:base)

    post admin_festival_edition_attendances_url(edition.festival, edition),
      params: { attendance: { critic_id: critic.id } },
      as: :turbo_stream

    assert_response :success
  end
end
