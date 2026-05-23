# frozen_string_literal: true

require "test_helper"

class FilmsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get film_url(films(:base))
    assert_response :success
  end

  test "walked out ratings are listed after non-walkout ratings" do
    selection = selections(:base)
    non_walkout_critic = Critic.create!(
      first_name: "Zed",
      last_name: "Zulu",
      publication: "Sight and Sound",
      country: "US",
    )
    walkout_critic = Critic.create!(
      first_name: "Ada",
      last_name: "Alpha",
      publication: "MUBI",
      country: "US",
    )

    Rating.create!(selection: selection, critic: non_walkout_critic, score: 0.0)
    Rating.create!(selection: selection, critic: walkout_critic, score: 4.0, walked_out: true)

    get film_url(selection.film)
    assert_response :success

    assert_operator(response.body.index(non_walkout_critic.name), :<, response.body.index(walkout_critic.name))
  end
end
