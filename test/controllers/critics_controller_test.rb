# frozen_string_literal: true

require "test_helper"

class CriticsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get critic_url(critics(:base))
    assert_response :success
  end

  test "walked out ratings are listed after non-walkout ratings" do
    critic = critics(:unaffiliated)
    Attendance.create!(critic: critic, edition: editions(:base))
    Rating.create!(selection: selections(:base), critic: critic, score: 0.0)
    Rating.create!(selection: selections(:with_original_title), critic: critic, walked_out: true)

    get critic_url(critic)
    assert_response :success

    assert_operator(
      response.body.index(films(:base).title),
      :<,
      response.body.index(films(:with_original_title).title),
    )
  end
end
