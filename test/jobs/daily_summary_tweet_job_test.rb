# frozen_string_literal: true

require "test_helper"

class DailySummaryTweetJobTest < ActiveJob::TestCase
  # setup do
  #   X::Client.any_instance.stubs(:post).returns(true)
  # end

  test "should do nothing if no current editions" do
    edition = editions(:base)
    edition.update(start_date: 2.weeks.ago, end_date: 1.week.ago)

    X::Client.any_instance.expects(:post).never

    perform_enqueued_jobs do
      DailySummaryTweetJob.perform_later
    end
  end

  test "should do nothing if no ratings" do
    edition = editions(:base)
    edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
    Rating.destroy_all

    X::Client.any_instance.expects(:post).never

    perform_enqueued_jobs do
      DailySummaryTweetJob.perform_later
    end
  end

  test "should do nothing if no new ratings" do
    edition = editions(:base)
    edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
    edition.ratings.update_all(created_at: 2.days.ago)

    X::Client.any_instance.expects(:post).never

    perform_enqueued_jobs do
      DailySummaryTweetJob.perform_later
    end
  end

  test "should tweet daily summary" do
    edition = editions(:base)
    edition.update(start_date: 1.week.ago, end_date: 1.week.from_now)
    edition.selections.find_each(&:cache_average_rating)

    tweet = <<~TWEET
      ⭐️ TIFF24 Day 8 Ratings ⭐️

      There were 3 ratings from our critics across 2 films. Here are the new averages for rated films:

      • Festival Film -> 3.5
      • With Original Title -> 4.5

      Visit http://localhost:3000/editions/tiff24 for detailed ratings
    TWEET

    X::Client.any_instance.expects(:post).with("tweets", { text: tweet }.to_json).returns(true)

    perform_enqueued_jobs do
      DailySummaryTweetJob.perform_later
    end
  end
end
