# frozen_string_literal: true

require "test_helper"

class Share::Content::EditionTopFilmsTest < ActiveSupport::TestCase
  # editions(:base) already has two fixture selections with >= 4 ratings each
  # (selections(:base), selections(:with_original_title)) — using it here would
  # let unrelated fixture data leak into the ranking under test. with_no_films
  # starts with zero selections/categories, so every selection in these tests
  # is one this test created on purpose.
  setup do
    @edition = editions(:with_no_films)
    @category = Category.create!(edition: @edition, name: "Category")
  end

  test "#slides ranks selections by bayesian score, best first" do
    high = rated_selection(title: "High Score", scores: [5.0, 5.0, 5.0, 5.0])
    low = rated_selection(title: "Low Score", scores: [1.0, 1.0, 1.0, 1.0])

    slides = Share::Content::EditionTopFilms.new(@edition).slides

    assert_equal [high, low], slides.map(&:selection)
    assert_equal [1, 2], slides.map(&:rank)
  end

  test "#slides excludes selections with fewer than 4 ratings" do
    rated_selection(title: "Too Few Ratings", scores: [5.0, 5.0])

    assert_empty Share::Content::EditionTopFilms.new(@edition).slides
  end

  test "#slides respects the limit option" do
    5.times { |n| rated_selection(title: "Film #{n}", scores: [4.0, 4.0, 4.0, 4.0]) }

    slides = Share::Content::EditionTopFilms.new(@edition, limit: 3).slides

    assert_equal 3, slides.size
  end

  test "#card_class_for always returns Share::Card::FilmRank" do
    rated_selection(title: "Any Film", scores: [4.0, 4.0, 4.0, 4.0])
    content = Share::Content::EditionTopFilms.new(@edition)

    assert_equal Share::Card::FilmRank, content.card_class_for(content.slides.first)
  end

  test "#caption lists ranked film titles and links to the edition" do
    rated_selection(title: "Great Film", scores: [5.0, 5.0, 5.0, 5.0])

    caption = Share::Content::EditionTopFilms.new(@edition).caption

    assert_includes caption, "1. Great Film"
    assert_includes caption, "http://localhost:3000/editions/tiff25"
  end

  private

  def rated_selection(title:, scores:)
    film = Film.create!(title: title, director: "Test Director", country: "US", year: 2026)
    selection = Selection.create!(edition: @edition, film: film, category: @category)
    raters = [critics(:base), critics(:without_publication), critics(:without_ratings), critics(:frequent_rater), critics(:contrarian)]
    scores.each_with_index do |score, i|
      Rating.create!(critic: raters[i], selection: selection, score: score, skip_cache_average_ratings_callback: true)
    end
    selection
  end
end
