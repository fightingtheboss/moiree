# frozen_string_literal: true

require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

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

  # --- #ratings ---

  test "#ratings returns the critic's native and inherited ratings at the edition" do
    attendance = attendances(:base)
    new_film = Film.create!(title: "New Film", director: "New Director", country: "US", year: 2024)
    new_selection = Selection.create!(edition: attendance.edition, film: new_film, category: categories(:base))
    inherited = Rating.create!(
      critic: critics(:base),
      selection: new_selection,
      score: 3.0,
      source_edition_id: editions(:with_no_films).id,
      skip_cache_average_ratings_callback: true,
    )

    assert_equal [ratings(:base), inherited, ratings(:with_original_title)].sort_by(&:id), attendance.ratings.sort_by(&:id)
  end

  # --- before_destroy :destroy_ratings ---

  test "destroying an Attendance destroys the critic's native and inherited ratings for that edition" do
    critic = critics(:without_ratings)
    attendance = Attendance.create!(critic:, edition: editions(:base))
    native = ratings(:without_ratings_original)
    inherited = Rating.create!(
      critic:,
      selection: selections(:base),
      score: 3.5,
      source_edition_id: editions(:with_no_films).id,
      skip_cache_average_ratings_callback: true,
    )

    assert_difference "Rating.count", -2 do
      attendance.destroy
    end

    assert_not Rating.exists?(native.id)
    assert_not Rating.exists?(inherited.id)
  end

  test "destroying an Attendance preserves the critic's ratings at other editions" do
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
    other_native = create_rating(critic: critics(:base), selection: other_selection, score: 4.0)

    attendances(:base).destroy

    assert Rating.exists?(other_native.id)
  end

  test "destroying an Attendance recomputes the averages of the selections it rated" do
    selection = selections(:base)
    critic = critics(:without_publication)
    attendance = Attendance.create!(critic:, edition: selection.edition)
    selection.cache_average_rating
    selection.film.cache_overall_average_rating

    perform_enqueued_jobs { attendance.destroy }

    # critics(:base) is the only remaining attending critic who rated selections(:base)
    assert_equal 3.5, selection.reload.average_rating
    # ratings(:without_publication) (2.5) is gone: (3.5 + 1.0 + 1.5) / 3
    assert_equal 2.0, selection.film.reload.overall_average_rating
  end
end
