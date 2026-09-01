# frozen_string_literal: true

require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  # --- after_commit :enqueue_inherit_ratings ---

  test "creating an Attendance enqueues InheritRatingsForAttendanceJob" do
    critic = critics(:without_ratings)
    edition = editions(:base)

    InheritRatingsForAttendanceJob.expects(:perform_later).once

    Attendance.create!(critic: critic, edition: edition)
  end

  test "updating an Attendance does not enqueue InheritRatingsForAttendanceJob" do
    attendance = attendances(:base)

    InheritRatingsForAttendanceJob.expects(:perform_later).never

    attendance.update!(publication: "Updated Publication")
  end

  # --- before_destroy :destroy_inherited_ratings ---

  test "destroying an Attendance deletes the critic's inherited ratings for that edition" do
    # Create an attendance for a critic
    critic = critics(:without_ratings)
    edition = editions(:base)
    attendance = Attendance.create!(critic: critic, edition: edition)

    # Create a new selection with no ratings yet
    new_film = Film.create!(title: "New Film", director: "New Director", country: "US", year: 2024)
    category = edition.categories.first
    new_selection = Selection.create!(edition: edition, film: new_film, category: category)

    # Create an inherited rating for this critic at this edition
    inherited_rating = Rating.create!(
      critic: critic,
      selection: new_selection,
      score: 3.5,
      source_edition_id: editions(:with_no_films).id,
      skip_cache_average_ratings_callback: true,
    )

    assert_difference "Rating.count", -1 do
      attendance.destroy
    end

    assert_not Rating.exists?(inherited_rating.id)
  end

  test "destroying an Attendance preserves the critic's native ratings for that edition" do
    # Create an attendance for a critic that has a native rating at this edition
    critic = critics(:base)
    edition = editions(:base)
    attendance = Attendance.find_by!(critic: critic, edition: edition)
    native_rating = ratings(:base) # native rating for critics(:base) at selections(:base)

    assert_no_difference "Rating.count" do
      attendance.destroy
    end

    assert Rating.exists?(native_rating.id)
  end

  test "destroying an Attendance only deletes inherited ratings for that edition, not others" do
    # Set up: critic has an inherited rating at editions(:base) AND a native rating at another edition
    other_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "OTHER25",
      start_date: "2025-01-01",
      end_date: "2025-01-10",
      slug: "other25",
    )
    other_category = Category.create!(edition: other_edition, name: "Main", position: 1)
    other_selection = Selection.create!(edition: other_edition, film: films(:base), category: other_category)

    other_native = Rating.create!(
      critic: critics(:base),
      selection: other_selection,
      score: 4.0,
      skip_cache_average_ratings_callback: true,
    )

    inherited_at_base = Rating.create!(
      critic: critics(:without_ratings),
      selection: selections(:base),
      score: 3.0,
      source_edition_id: other_edition.id,
      skip_cache_average_ratings_callback: true,
    )

    Attendance.create!(critic: critics(:without_ratings), edition: editions(:base))
    attendance = Attendance.find_by(critic: critics(:without_ratings), edition: editions(:base))

    assert_difference "Rating.count", -1 do
      attendance.destroy
    end

    assert_not Rating.exists?(inherited_at_base.id)
    assert Rating.exists?(other_native.id)
  end

  test "destroying an Attendance does not enqueue CacheAverageRatingJob for deleted inherited ratings" do
    critic = critics(:without_ratings)
    edition = editions(:base)
    attendance = Attendance.create!(critic: critic, edition: edition)

    new_film = Film.create!(title: "New Film", director: "New Director", country: "US", year: 2024)
    category = edition.categories.first
    new_selection = Selection.create!(edition: edition, film: new_film, category: category)

    Rating.create!(
      critic: critic,
      selection: new_selection,
      score: 3.5,
      source_edition_id: editions(:with_no_films).id,
      skip_cache_average_ratings_callback: true,
    )

    CacheAverageRatingJob.expects(:perform_later).never

    attendance.destroy
  end
end
