# frozen_string_literal: true

require "test_helper"

class FilmsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get film_url(films(:base))
    assert_response :success
  end

  test "walked out ratings are listed after non-walkout ratings" do
    selection = selections(:base)
    non_walkout_critic = critics(:without_ratings)
    walkout_critic = critics(:unaffiliated)

    Rating.create!(selection: selection, critic: non_walkout_critic, score: 0.0)
    Rating.create!(selection: selection, critic: walkout_critic, walked_out: true)

    get film_url(selection.film)
    assert_response :success

    assert_operator(response.body.index(non_walkout_critic.name), :<, response.body.index(walkout_critic.name))
  end
end
