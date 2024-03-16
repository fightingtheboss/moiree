# frozen_string_literal: true

require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "#films should return the Films associated with the Category" do
    category = categories(:base)
    film = films(:base)

    assert category.films.include?(film)
  end

  test "#ratings should return the Ratings associated with the Category" do
    category = categories(:base)
    rating = ratings(:base)

    assert category.ratings.include?(rating)
  end

  test "#overall_average_rating should return the average Rating of all Films in the Category" do
    category = categories(:base)

    assert_equal 3.0, category.overall_average_rating
  end
end
