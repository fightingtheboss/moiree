# frozen_string_literal: true

require "test_helper"

class FilmTest < ActiveSupport::TestCase
  test "#ratings should return the Ratings associated with the Film" do
    film = films(:base)
    rating = ratings(:base)

    assert(film.ratings.include?(rating))
  end

  test "#categories should return the Categories associated with the Film" do
    film = films(:base)
    category = categories(:base)

    assert(film.categories.include?(category))
  end

  test "#category should return nil if no Category is associated with the film" do
    film = films(:with_multiple_directors)
    edition = editions(:base)

    assert_nil(film.category(edition: edition))
  end

  test "#category should return the Category associated with the Film for the given Edition" do
    film = films(:base)
    edition = editions(:base)
    category = categories(:base)

    assert_equal(category, film.category(edition: edition))
  end

  test "#cache_overall_average_rating should update overall_average_rating" do
    film = films(:base)
    film.update(overall_average_rating: nil)

    film.cache_overall_average_rating

    assert_equal 3.0, film.overall_average_rating
  end

  test "#search with no query returns all films" do
    assert_equal Film.all.count, Film.search(nil).count
  end

  test "#search with a query returns films that match the query" do
    film = films(:base)

    assert_includes Film.search(film.title), film
  end

  test "#search with an edition_id returns films that are associated with the edition" do
    film = films(:base)
    edition = editions(:base)

    assert_includes Film.search(nil, edition_id: edition.id), film
  end

  test "#search with an edition_id and exclude: true returns films that are not associated with the edition" do
    film = films(:base)
    edition = editions(:base)

    refute_includes Film.search(nil, edition_id: edition.id, exclude: true), film
  end

  test "#search_within_edition is an alias for #search with an edition_id" do
    film = films(:base)
    edition = editions(:base)

    assert_includes Film.search_within_edition(nil, edition.id), film
  end

  test "#search_excluding_edition is an alias for #search with an edition_id and exclude: true" do
    film = films(:base)
    edition = editions(:base)

    refute_includes Film.search_excluding_edition(nil, edition.id), film
  end

  test "::import should return an ImportResult" do
    file = fixture_file_upload("films.csv", "text/csv")
    edition = editions(:base)

    assert_instance_of ImportResult, Film.import(file, edition)
  end

  test "::import should import films from a CSV file" do
    file = fixture_file_upload("films.csv", "text/csv")
    edition = editions(:with_no_films)

    assert_difference "Film.count", 2 do
      Film.import(file, edition)
    end
  end

  test "::import should not create a film if it already exists" do
    file = fixture_file_upload("existing_film.csv", "text/csv")
    edition = editions(:base)

    assert_no_difference "Film.count" do
      Film.import(file, edition)
    end
  end

  test "::import should create a new Category if one does not exist" do
    file = fixture_file_upload("films.csv", "text/csv")
    edition = editions(:with_no_films)

    assert_difference "Category.count", 3 do
      Film.import(file, edition)
    end
  end

  test "::import should not create a new Category if one already exists" do
    file = fixture_file_upload("new_film_existing_category.csv", "text/csv")
    edition = editions(:base)

    assert_difference "Film.count" do
      assert_no_difference "Category.count" do
        Film.import(file, edition)
      end
    end
  end

  test "::import should not import a film if the directors do not match" do
    file = fixture_file_upload("existing_film_different_director.csv", "text/csv")
    edition = editions(:base)

    assert_no_difference "Film.count" do
      import_result = Film.import(file, edition)

      assert_equal 1, import_result.skipped.size
      assert_equal "Festival Film has different directors (Sarah Polley) from imported film (Edward Yang)",
        import_result.errors.first
    end
  end

  private

  def fixture_file_upload(path, mime_type = nil)
    Rack::Test::UploadedFile.new(File.join(ActionDispatch::IntegrationTest.file_fixture_path, path), mime_type)
  end
end
