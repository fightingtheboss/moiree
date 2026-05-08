# frozen_string_literal: true

require "test_helper"

class DailySummaryTweetJobTest < ActiveJob::TestCase
  def premiere_selection(edition:, title:, director:, score: 3.0)
    film = Film.create!(title: title, director: director, country: "FR", year: 2026)
    selection = Selection.create!(edition: edition, film: film, category: categories(:base))
    [critics(:base), critics(:without_publication), critics(:without_ratings), critics(:frequent_rater)].each do |critic|
      Attendance.find_or_create_by!(critic: critic, edition: edition)
      Rating.create!(selection: selection, critic: critic, score: score, created_at: 1.hour.ago)
    end
    selection.cache_average_rating
    selection
  end

  test "should do nothing if no current editions" do
    edition = editions(:base)
    edition.update(start_date: 2.weeks.ago, end_date: 1.week.ago)

    DailySummaryTweet.any_instance.expects(:post!).never

    perform_enqueued_jobs { DailySummaryTweetJob.perform_later }
  end

  test "should do nothing if no premiere selections" do
    edition = editions(:base)
    edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
    # All existing fixture ratings have old created_at — no premieres

    DailySummaryTweet.any_instance.expects(:post!).never

    perform_enqueued_jobs { DailySummaryTweetJob.perform_later }
  end

  test "should post daily summary when premiere selections exist" do
    travel_to Time.zone.local(2026, 5, 7) do
      edition = editions(:base)
      edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
      premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

      expected_text = <<~TWEET.chomp
        TIFF24: May 7 Recap

        PREMIERE FILM (Smith): 3.00 from 4 ratings

        Check out all of our critics scores from the festival here: http://localhost:3000/editions/tiff24
      TWEET

      X::Client.any_instance.expects(:post).with("tweets", { text: expected_text }.to_json).returns(true)

      perform_enqueued_jobs { DailySummaryTweetJob.perform_later }
    end
  end
end
