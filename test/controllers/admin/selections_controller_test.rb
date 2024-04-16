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
        film_attributes: {
          title: "New Film",
          director: "Director",
          year: 2024,
          categorizations_attributes: {
            "0" => {
              category_id: categories(:base).id,
            },
          },
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
            film_attributes: {
              title: "New Film",
              director: "Director",
              year: 2024,
              categorizations_attributes: {
                "0" => {
                  category_id: categories(:base).id,
                },
              },
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
            film_id: films(:with_multiple_countries).id,
            film_attributes: {
              id: films(:with_multiple_countries).id,
              categorizations_attributes: {
                "0" => {
                  category_id: categories(:base).id,
                },
              },
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
          film_attributes: {
            title: "New Film",
            director: "Director",
            year: 2024,
            categorizations_attributes: {
              "0" => {
                category_id: "-1",
              },
            },
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

    assert_redirected_to admin_festival_edition_path(@edition.festival, @edition)
  end
end
