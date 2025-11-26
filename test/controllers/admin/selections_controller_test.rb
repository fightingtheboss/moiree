# frozen_string_literal: true

require "test_helper"

class Admin::SelectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:admin))
    @edition = editions(:base)
  end

  test "should get new without film_id" do
    get new_admin_festival_edition_selection_url(@edition.festival, @edition)
    assert_response :success
  end

  test "should get new with film_id" do
    film = films(:base)
    get new_admin_festival_edition_selection_url(@edition.festival, @edition, film_id: film.id)
    assert_response :success
  end

  test "should redirect to Editions#show on successful #create" do
    post admin_festival_edition_selections_url(@edition.festival, @edition, params: {
      film: {
        country: ["CA", "US"],
      },
      selection: {
        category_id: categories(:base).id,
        film_attributes: {
          title: "New Film",
          director: "Director",
          year: 2024,
        },
      },
    })

    assert_redirected_to admin_festival_edition_path(@edition.festival, @edition)
  end

  test "should create a new Selection with a new Film" do
    assert_difference("Selection.count") do
      assert_difference("Film.count") do
        post admin_festival_edition_selections_url(@edition.festival, @edition, params: {
          film: {
            country: ["CA", "US"],
          },
          selection: {
            category_id: categories(:base).id,
            film_attributes: {
              title: "New Film",
              director: "Director",
              year: 2024,
            },
          },
        })
      end
    end
  end

  test "should create a new Selection with an existing Film" do
    assert_difference("Selection.count") do
      assert_no_difference("Film.count") do
        post admin_festival_edition_selections_url(@edition.festival, @edition, params: {
          selection: {
            category_id: categories(:base).id,
            film_attributes: {
              id: films(:with_multiple_countries).id,
            },
          },
        })
      end
    end
  end

  test "should create a new Category" do
    assert_difference("Category.count") do
      post admin_festival_edition_selections_url(@edition.festival, @edition, params: {
        film: {
          country: ["CA", "US"],
        },
        selection: {
          category_id: "-1",
          film_attributes: {
            title: "New Film",
            director: "Director",
            year: 2024,
          },
        },
        new_category: "New Category",
      })
    end
  end

  test "should import selections from a CSV" do
    assert_difference("Selection.count", 2) do
      post import_admin_festival_edition_selections_url(@edition.festival, @edition), params: {
        edition: {
          csv: fixture_file_upload("films.csv"),
        },
      }
    end
  end

  test "should redirect to Editions#show on successful #import" do
    post import_admin_festival_edition_selections_url(@edition.festival, @edition), params: {
      edition: {
        csv: fixture_file_upload("films.csv"),
      },
    }

    assert_redirected_to admin_festival_edition_url(@edition.festival, @edition)
  end

  test "should get new with tmdb_id" do
    tmdb_movie = stub(
      title: "TMDB Film",
      original_title: "Original TMDB Film",
      directors: ["Director 1"],
      countries: ["US"],
      release_date: "2024-01-01",
      overview: "A film from TMDB",
      poster_path: "/poster.jpg",
      backdrop_path: "/backdrop.jpg",
      id: 12345,
    )
    TMDB.stubs(:find).with("12345").returns(tmdb_movie)

    get new_admin_festival_edition_selection_url(@edition.festival, @edition, tmdb_id: 12345)

    assert_response :success
    assert_select "input[value='TMDB Film']"
  end

  test "should get edit" do
    selection = selections(:base)
    get edit_admin_festival_edition_selection_url(@edition.festival, @edition, selection)
    assert_response :success
  end

  test "should get edit with tmdb_id" do
    selection = selections(:base)
    tmdb_movie = stub(
      title: "Updated TMDB Film",
      original_title: "Original Updated TMDB Film",
      directors: ["Director 1"],
      countries: ["US"],
      release_date: "2024-06-01",
      overview: "An updated film from TMDB",
      poster_path: "/updated_poster.jpg",
      backdrop_path: "/updated_backdrop.jpg",
      id: 67890,
    )
    TMDB.stubs(:find).with("67890").returns(tmdb_movie)

    get edit_admin_festival_edition_selection_url(@edition.festival, @edition, selection, tmdb_id: 67890)

    assert_response :success
    assert_select "input[value='Updated TMDB Film']"
  end

  test "should update selection and film" do
    selection = selections(:base)
    film = selection.film

    patch admin_festival_edition_selection_url(@edition.festival, @edition, selection), params: {
      film: {
        country: ["FR", "IT"],
      },
      selection: {
        category_id: categories(:base).id,
        film_attributes: {
          id: film.id,
          title: "Updated Film Title",
          director: "Updated Director",
          year: 2025,
          tmdb_id: 67890,
        },
      },
    }

    assert_redirected_to admin_festival_edition_path(@edition.festival, @edition)

    film.reload
    assert_equal "Updated Film Title", film.title
    assert_equal "Updated Director", film.director
    assert_equal 2025, film.year
    assert_equal "FR,IT", film.country
    assert_equal 67890, film.tmdb_id
  end

  test "should update selection with new category" do
    selection = selections(:base)
    film = selection.film

    assert_difference("Category.count") do
      patch admin_festival_edition_selection_url(@edition.festival, @edition, selection), params: {
        film: {
          country: ["US"],
        },
        selection: {
          category_id: "-1",
          film_attributes: {
            id: film.id,
            title: film.title,
            director: film.director,
            year: film.year,
          },
        },
        new_category: "Brand New Category",
      }
    end

    selection.reload
    assert_equal "Brand New Category", selection.category.name
  end
end
