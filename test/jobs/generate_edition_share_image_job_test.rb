# frozen_string_literal: true

require "test_helper"

class GenerateEditionShareImageJobTest < ActiveJob::TestCase
  test "enqueues a job per current edition when called with :all" do
    # create two current editions
    Edition.create!(
      festival: festivals(:base),
      year: Date.current.year,
      code: "CURR1",
      start_date: Date.current - 1.day,
      end_date: Date.current + 1.day,
    )

    Edition.create!(
      festival: festivals(:base),
      year: Date.current.year,
      code: "CURR2",
      start_date: Date.current - 2.days,
      end_date: Date.current + 2.days,
    )

    # When performing the job for :all it should enqueue one job per current edition
    assert_enqueued_jobs 2 do
      GenerateEditionShareImageJob.perform_now(:all)
    end
  end

  test "generates and attaches a share image for a single edition" do
    edition = Edition.create!(
      festival: festivals(:base),
      year: Date.current.year + 1,
      code: "SINGLE",
      start_date: Date.current + 30.days,
      end_date: Date.current + 40.days,
    )

    assert_not edition.share_image.attached?

    perform_enqueued_jobs do
      GenerateEditionShareImageJob.perform_now(edition.id)
    end

    edition.reload
    assert edition.share_image.attached?, "Share image should be attached after job runs"
  end
end
