# frozen_string_literal: true

require "test_helper"

class Admin::RatingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:admin))
    @festival = festivals(:base)
    @edition = editions(:base)
    @selection = selections(:base)
  end

  test "new form includes walked out checkbox support text" do
    get new_admin_festival_edition_selection_rating_path(@festival, @edition, @selection)

    assert_response :success
    assert_select("input[name='rating[walked_out]'][type='checkbox']")
    assert_select("p", text: "A walked out rating doesn't count towards averages.")
  end

  test "edit form disables score slider for walked out rating" do
    rating = Rating.create!(
      score: 5.0,
      walked_out: true,
      critic: critics(:without_ratings),
      selection: @selection,
      skip_cache_average_ratings_callback: true,
    )

    get edit_admin_festival_edition_selection_rating_path(@festival, @edition, @selection, rating)

    assert_response :success
    assert_select("input[name='rating[score]'][disabled]")
  end

  test "create normalizes score to zero for walked out rating" do
    assert_difference("Rating.count", 1) do
      post admin_festival_edition_selection_ratings_path(@festival, @edition, @selection), params: {
        rating: {
          score: 4.5,
          walked_out: true,
          critic_id: critics(:without_ratings).id,
        },
      }
    end

    rating = Rating.order(:id).last
    assert(rating.walked_out?)
    assert_equal(0.0, rating.score.to_f)
  end
end
