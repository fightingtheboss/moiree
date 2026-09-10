# frozen_string_literal: true

require "test_helper"

class Share::Card::FilmRankTest < ActiveSupport::TestCase
  Slide = Struct.new(:selection, :rank, :bayesian_score)

  test "#build returns an image with the exact requested dimensions" do
    slide = Slide.new(selections(:base), 1, 4.2)

    image = Share::Card::FilmRank.new(slide).build(width: 1080, height: 1080)

    assert_equal 1080, image.width
    assert_equal 1080, image.height
  end

  test "#build works for a different aspect ratio without raising" do
    slide = Slide.new(selections(:base), 3, 3.75)

    image = Share::Card::FilmRank.new(slide).build(width: 1080, height: 1350)

    assert_equal 1080, image.width
    assert_equal 1350, image.height
  end

  test "#build produces an opaque image (no alpha band) suitable for a feed post" do
    slide = Slide.new(selections(:base), 1, 4.2)

    image = Share::Card::FilmRank.new(slide).build(width: 500, height: 500)

    assert_equal 3, image.bands
  end

  test "#build does not raise for a title containing Pango markup characters" do
    slide = Slide.new(selection_with_title("Fire & Ice <Test> \"q\" it's"), 1, 4.2)

    image = Share::Card::FilmRank.new(slide).build(width: 1080, height: 1080)

    assert_equal 1080, image.width
    assert_equal 1080, image.height
  end

  test "#build stays within the requested width for a very long title" do
    title = "An Extraordinarily Long Film Title That Would Otherwise Overflow The Canvas Edge Entirely"
    slide = Slide.new(selection_with_title(title), 1, 4.2)

    image = Share::Card::FilmRank.new(slide).build(width: 1080, height: 1080)

    assert_equal 1080, image.width
    assert_equal 1080, image.height
  end

  private

  def selection_with_title(title)
    edition = editions(:with_no_films)
    category = Category.create!(edition: edition, name: "Category #{SecureRandom.hex(4)}")
    film = Film.create!(title: title, director: "Test Director", country: "US", year: 2026)
    Selection.create!(edition: edition, film: film, category: category)
  end
end
