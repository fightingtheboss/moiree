# frozen_string_literal: true

require "test_helper"

class SelectionTest < ActiveSupport::TestCase
  test "should not be valid if required fields are not present" do
    selection = Selection.new

    assert_not(selection.valid?)
  end

  test "should be valid with all required fields present" do
    selection = selections(:base)

    assert(selection.valid?)
  end

  # --- cache_average_rating ---

  test "#cache_average_rating includes inherited ratings from attending critics" do
    selection = selections(:base)
    critic = critics(:without_publication)
    Attendance.create!(critic:, edition: selection.edition)
    ratings(:without_publication).update_columns(source_edition_id: editions(:with_no_films).id)

    selection.cache_average_rating

    # critics(:base) native 3.5 + critics(:without_publication) inherited 2.5
    assert_equal 3.0, selection.reload.average_rating
  end

  test "#cache_average_rating excludes ratings from critics not attending the edition" do
    selection = selections(:base)

    selection.cache_average_rating

    # Only critics(:base) (3.5) attends editions(:base)
    assert_equal 3.5, selection.reload.average_rating
  end

  # --- ratings_standard_deviation ---

  test "#ratings_standard_deviation returns 0 when fewer than 4 rated ratings" do
    selection = selections(:base)
    ratings(:contrarian_base).update_columns(walked_out: true, score: 0.0)

    assert_equal 0, selection.ratings_standard_deviation
  end

  test "#ratings_standard_deviation includes inherited ratings" do
    selection = selections(:base)
    expected = selection.ratings_standard_deviation

    ratings(:contrarian_base).update_columns(source_edition_id: editions(:with_no_films).id)

    assert_equal expected, selection.reload.ratings_standard_deviation
    assert_operator expected, :>, 0
  end

  # --- after_commit callback ---

  test "creating a Selection enqueues InheritRatingsForSelectionJob" do
    edition = editions(:base)
    category = categories(:base)

    new_film = Film.create!(
      title: "New Film For Callback Test",
      normalized_title: "New Film For Callback Test",
      director: "Director",
      country: "US",
      year: 2024,
    )

    InheritRatingsForSelectionJob.expects(:perform_later).once

    Selection.create!(edition: edition, film: new_film, category: category)
  end

  test "#featured_rating excludes walked out ratings" do
    selection = selections(:base)

    Rating.create!(
      score: 5.0,
      walked_out: true,
      impression: "Left after 20 minutes",
      critic: critics(:without_ratings),
      selection: selection,
      skip_cache_average_ratings_callback: true,
    )

    assert_nil(selection.featured_rating)
  end

  test "#cache_average_rating excludes walked out ratings from the average" do
    selection = selections(:base)
    critic = critics(:without_ratings)
    Attendance.create!(critic: critic, edition: selection.edition)

    Rating.create!(
      score: 5.0,
      critic: critic,
      selection: selection,
      walked_out: true,
      skip_cache_average_ratings_callback: true,
    )

    selection.update!(average_rating: nil)
    selection.cache_average_rating

    assert_equal(3.5, selection.reload.average_rating.to_f)
  end
end
