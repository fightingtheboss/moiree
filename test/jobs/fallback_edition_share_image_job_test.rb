# frozen_string_literal: true

require "test_helper"

class FallbackEditionShareImageJobTest < ActiveJob::TestCase
  test "generates and attaches fallback share image" do
    edition = Edition.create!(
      festival: festivals(:base),
      year: 2026,
      code: "TIFF26",
      start_date: Date.new(2026, 9, 9),
      end_date: Date.new(2026, 9, 19),
    )

    assert_not edition.share_image.attached?

    perform_enqueued_jobs do
      FallbackEditionShareImageJob.perform_now(edition.id)
    end

    edition.reload

    assert edition.share_image.attached?, "Fallback share image should be attached"
  end
end
