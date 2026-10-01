# frozen_string_literal: true

require "test_helper"

class CacheEditionAverageRatingsJobTest < ActiveJob::TestCase
  test "recomputes the edition's average ratings" do
    edition = editions(:base)
    edition.selections.update_all(average_rating: 0)

    CacheEditionAverageRatingsJob.perform_now(edition)

    assert_equal 3.5, selections(:base).reload.average_rating
  end

  test "is discarded when the edition no longer exists" do
    edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "GONE25",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "gone25",
    )
    CacheEditionAverageRatingsJob.perform_later(edition)
    edition.destroy!

    assert_nothing_raised { perform_enqueued_jobs }
  end
end
