# frozen_string_literal: true

require "test_helper"

class EditionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get edition_url(editions(:base))
    assert_response :success
  end

  test "show sets public cache control for HTTP caching" do
    get edition_url(editions(:base))
    assert_response :success
    assert response.headers["Cache-Control"].include?("public")
  end

  test "show returns 304 when edition has not changed" do
    edition = editions(:base)
    get edition_url(edition)
    assert_response :success

    get edition_url(edition), headers: { "If-None-Match" => response.etag }
    assert_response :not_modified
  end

  test "show orders selections case-insensitively and ignoring leading articles" do
    edition = editions(:base)
    zebra = premiere_selection(edition: edition, title: "zebra", director: "Test", num_ratings: 0)
    apple = premiere_selection(edition: edition, title: "The Apple", director: "Test", num_ratings: 0)
    banana = premiere_selection(edition: edition, title: "BANANA", director: "Test", num_ratings: 0)

    get edition_url(edition)

    apple_index = response.body.index(apple.film.title)
    banana_index = response.body.index(banana.film.title)
    zebra_index = response.body.index(zebra.film.title)

    assert_operator apple_index, :<, banana_index
    assert_operator banana_index, :<, zebra_index
  end

  test "show puts the inherited ratings breakdown on the focusable average cell without an icon" do
    edition = editions(:base)
    selection = premiere_selection(edition:, title: "Inherited", director: "Test", num_ratings: 1)
    Rating.create!(
      selection:,
      critic: critics(:without_publication),
      score: 4.0,
      source_edition: editions(:with_no_films),
      skip_cache_average_ratings_callback: true,
    )

    get edition_url(edition)

    assert_select "td[tabindex='0']", text: /1 here \+ 1 from earlier festivals/ do
      assert_select "svg", count: 0
    end
  end
end
