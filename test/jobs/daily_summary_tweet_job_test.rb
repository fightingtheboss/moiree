# frozen_string_literal: true

require "test_helper"

class DailySummaryTweetJobTest < ActiveJob::TestCase
  test "should do nothing if no current editions" do
    travel_to Time.zone.local(2026, 5, 10, 23, 50, 0) do
      edition = editions(:base)
      edition.update(start_date: 2.weeks.ago, end_date: 1.week.ago)

      DailySummaryTweet.any_instance.expects(:post!).never

      perform_enqueued_jobs { DailySummaryTweetJob.perform_later }
    end
  end

  test "should skip edition when local time is outside the tweet window" do
    travel_to Time.zone.local(2026, 5, 10, 22, 0, 0) do # 10pm UTC — before window
      festivals(:base).update!(timezone: "UTC")
      edition = editions(:base)
      edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
      premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

      DailySummaryTweet.any_instance.expects(:post!).never

      perform_enqueued_jobs { DailySummaryTweetJob.perform_later }
    end
  end

  test "should do nothing if no premiere selections" do
    travel_to Time.zone.local(2026, 5, 10, 23, 50, 0) do # 11:50pm UTC — inside window
      festivals(:base).update!(timezone: "UTC")
      edition = editions(:base)
      edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
      # All existing fixture ratings have old created_at — none pass today's beginning_of_day cutoff

      DailySummaryTweet.any_instance.expects(:post!).never

      perform_enqueued_jobs { DailySummaryTweetJob.perform_later }
    end
  end

  test "should post daily summary when inside the window and premiere selections exist" do
    travel_to Time.zone.local(2026, 5, 10, 23, 50, 0) do # 11:50pm UTC — inside window
      festivals(:base).update!(timezone: "UTC")
      edition = editions(:base)
      edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
      premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

      expected_text = <<~TWEET.chomp
        TIFF24: May 10 Recap

        PREMIERE FILM (Smith): 3.00 from 4 ratings

        Check out all of our critics scores from the festival here: http://localhost:3000/editions/tiff24
      TWEET

      X::Client.any_instance.expects(:post).with("tweets", { text: expected_text }.to_json).returns(true)

      perform_enqueued_jobs { DailySummaryTweetJob.perform_later }
    end
  end

  test "should fire for a festival at its local 11:45pm even when UTC time differs" do
    # Paris (UTC+2): 11:50pm Paris = 9:50pm UTC
    travel_to Time.zone.local(2026, 5, 10, 21, 50, 0) do # 9:50pm UTC
      festivals(:base).update!(timezone: "Paris")
      edition = editions(:base)
      edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
      premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

      expected_text = <<~TWEET.chomp
        TIFF24: May 10 Recap

        PREMIERE FILM (Smith): 3.00 from 4 ratings

        Check out all of our critics scores from the festival here: http://localhost:3000/editions/tiff24
      TWEET

      X::Client.any_instance.expects(:post).with("tweets", { text: expected_text }.to_json).returns(true)

      perform_enqueued_jobs { DailySummaryTweetJob.perform_later }
    end
  end
end
