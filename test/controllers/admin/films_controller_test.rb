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

  test "should render search_for_film_to_add_to_edition without error when query parameter is not present" do
    edition = editions(:base)
    get admin_festival_edition_search_for_film_to_add_url(edition.festival, edition)
    assert_response :success
    assert_select "turbo-frame#new-film-search-results"
    assert_select "h3", text: "TMDB results", count: 0
  end
  
  test "should get lookup_by_tmdb_id with valid id" do
    edition = editions(:base)
    tmdb_movie = stub(
      id: 12345,
      title: "TMDB Film",
      original_title: "Original TMDB Film",
      directors: ["Director 1"],
      countries: ["US"],
      release_date: "2024-01-01",
      overview: "A film from TMDB",
      poster_path: "/poster.jpg",
      backdrop_path: "/backdrop.jpg",
      poster_url: "https://image.tmdb.org/t/p/w185/poster.jpg",
    )
    TMDB.stubs(:find).with("12345").returns(tmdb_movie)

    get admin_festival_edition_lookup_by_tmdb_id_url(edition.festival, edition),
      params: { tmdb_id: "12345" },
      as: :turbo_stream
    assert_response :success
  end

  test "should return error for lookup_by_tmdb_id with invalid id" do
    edition = editions(:base)
    not_found_movie = stub(id: nil, title: nil, overview: nil, release_date: nil, poster_path: nil)
    TMDB.stubs(:find).with("99999999").returns(not_found_movie)

    get admin_festival_edition_lookup_by_tmdb_id_url(edition.festival, edition),
      params: { tmdb_id: "99999999" },
      as: :turbo_stream
    assert_response :success
    assert_match(/Film not found/, response.body)
  end
end
