# frozen_string_literal: true

require "test_helper"

class Admin::FilmsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:admin))
  end

  test "should get search with no params" do
    get admin_films_search_url
    assert_response :success
  end

  test "should get search with query" do
    get admin_films_search_url, params: { query: "Title" }
    assert_response :success
  end

  test "should get search with query and edition_id" do
    edition = editions(:base)
    get admin_films_search_url, params: { query: "Title", edition_id: edition.id }
    assert_response :success
  end

  test "should get search with query, edition_id and exclude_films_in_edition" do
    edition = editions(:base)
    get admin_films_search_url, params: { query: "Title", edition_id: edition.id, exclude_films_in_edition: true }
    assert_response :success
  end

  test "should get search with edition_id" do
    edition = editions(:base)
    get admin_films_search_url, params: { edition_id: edition.id }
    assert_response :success
  end

  test "should get search with edition_id and exclude_films_in_edition" do
    edition = editions(:base)
    get admin_films_search_url, params: { edition_id: edition.id, exclude_films_in_edition: true }
    assert_response :success
  end

  test "should get search_for_film_to_add_to_edition" do
    edition = editions(:base)
    get admin_festival_edition_search_for_film_to_add_url(edition.festival, edition), params: { query: "Title" }
    assert_response :success
  end

  test "should render without error when query parameter is not present" do
    edition = editions(:base)
    get admin_festival_edition_search_for_film_to_add_url(edition.festival, edition)
    assert_response :success
    assert_select "turbo-frame#new-film-search-results"
    assert_select "h3", text: "TMDB results", count: 0
  end
end
