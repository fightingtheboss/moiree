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

  test "#overall_average_rating should be updated when a new Rating is added" do
    film = films(:base)
    overall_average_rating_before = film.overall_average_rating = film.ratings.average(:score).to_f # 3.0

    Rating.create!(score: 5, critic: critics(:without_publication), selection: selections(:base))

    assert_not_equal overall_average_rating_before, film.reload.overall_average_rating
    assert film.overall_average_rating > overall_average_rating_before
  end

  test "#overall_average_rating should be updated when a new Rating is removed" do
    film = films(:base)
    overall_average_rating_before = film.overall_average_rating = film.ratings.average(:score).to_f # 3.0

    film.ratings.last.destroy

    assert_not_equal overall_average_rating_before, film.reload.overall_average_rating
    assert film.overall_average_rating > overall_average_rating_before
  end
end
