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

  # --- native_ratings ---

  test "#native_ratings returns only ratings with no source_edition_id" do
    selection = selections(:base)
    native = ratings(:base) # source_edition_id: nil

    # Mark one rating as inherited
    ratings(:without_publication).update_columns(source_edition_id: editions(:with_no_films).id)

    assert_includes selection.native_ratings, native
    assert_not_includes selection.native_ratings, ratings(:without_publication)
  end

  # --- cache_average_rating ---

  test "#cache_average_rating updates average_rating using only native ratings" do
    selection = selections(:base)

    # ratings(:base) is native (score 3.5), ratings(:without_publication) is native (score 2.5)
    # Make without_publication inherited — should be excluded from average
    ratings(:without_publication).update_columns(source_edition_id: editions(:with_no_films).id)

    # Only critics(:base) (score 3.5) is attending and native — average should be 3.5
    selection.cache_average_rating

    assert_equal 3.5, selection.reload.average_rating
  end

  test "#cache_average_rating returns 0.0 when all ratings are inherited" do
    selection = selections(:base)

    # Mark all ratings as inherited
    selection.ratings.update_all(source_edition_id: editions(:with_no_films).id)

    selection.cache_average_rating

    assert_equal 0.0, selection.reload.average_rating
  end

  # --- ratings_standard_deviation ---

  test "#ratings_standard_deviation returns 0 when fewer than 4 native ratings" do
    selection = selections(:base)

    # Inherit all but 2 ratings — below threshold of 4
    selection.ratings.order(:id).first(2).each do |r|
      r.update_columns(source_edition_id: editions(:with_no_films).id)
    end

    assert_equal 0, selection.ratings_standard_deviation
  end

  test "#ratings_standard_deviation excludes inherited ratings from calculation" do
    selection = selections(:base)

    # Fixture: base (3.5), without_publication (2.5), frequent_rater (1.0), contrarian (1.5)
    # All native, avg 3.5 (as cached)
    selection.ratings_standard_deviation

    # Now inherit one rating — calculation should change
    ratings(:contrarian_base).update_columns(source_edition_id: editions(:with_no_films).id)

    # Only 3 native ratings now — should return 0
    assert_equal 0, selection.reload.ratings_standard_deviation
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
