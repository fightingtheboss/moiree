# frozen_string_literal: true

require "test_helper"

class DailySummaryTweetTest < ActiveSupport::TestCase
  test "#premiere_selections returns selections with first rating today in the festival timezone and at least 4 ratings" do
    edition = editions(:base)
    selection = premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

    assert_includes DailySummaryTweet.new(edition).premiere_selections, selection
  end

  test "#premiere_selections excludes selections with fewer than 4 ratings" do
    edition = editions(:base)
    selection = premiere_selection(edition: edition, title: "Few Ratings Film", director: "Jane Smith", num_ratings: 3)

    refute_includes DailySummaryTweet.new(edition).premiere_selections, selection
  end

  test "#premiere_selections excludes selections whose first rating was before today in the festival timezone" do
    edition = editions(:base)
    # selections(:base) has ratings from 1.week.ago — before today's midnight
    refute_includes DailySummaryTweet.new(edition).premiere_selections, selections(:base)
  end

  test "#premiere_selections uses festival-local midnight as the window cutoff" do
    # At 1am UTC, UTC-2 local time is 11pm the previous day.
    # beginning_of_day in UTC-2 = 2am UTC (midnight UTC-2).
    # A rating from 25 hours ago (before local midnight) should be excluded.
    travel_to Time.zone.local(2026, 5, 10, 1, 0, 0) do
      festivals(:base).update!(timezone: "Mid-Atlantic") # UTC-2
      edition = editions(:base)

      old_selection = premiere_selection(
        edition: edition,
        title: "Old Premiere",
        director: "Jane Smith",
        created_at: 25.hours.ago,
      )

      refute_includes DailySummaryTweet.new(edition).premiere_selections, old_selection
    end
  end

  test "#text returns the formatted premiere tweet" do
    travel_to Time.zone.local(2026, 5, 10, 23, 50, 0) do
      edition = editions(:base)
      premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

      expected = <<~TWEET.chomp
        TIFF24: May 10 Recap

        PREMIERE FILM (Smith): 3.00 from 4 ratings

        Check out all of our critics scores from the festival here: http://localhost:3000/editions/tiff24
      TWEET

      assert_equal expected, DailySummaryTweet.new(edition).text
    end
  end

  test "#text header uses festival-local date, not server date" do
    # At 1am UTC, a UTC-2 festival is still on May 9
    travel_to Time.zone.local(2026, 5, 10, 1, 0, 0) do
      festivals(:base).update!(timezone: "Mid-Atlantic") # UTC-2
      edition = editions(:base)

      assert_equal "TIFF24: May 9 Recap\n\n", DailySummaryTweet.new(edition).send(:header)
    end
  end

  test "#text truncates the film list when tweet exceeds 280 characters" do
    travel_to Time.zone.local(2026, 5, 10, 23, 50, 0) do
      edition = editions(:base)
      ["Alpha", "Beta", "Gamma", "Delta"].each do |name|
        premiere_selection(
          edition: edition,
          title: "A Very Long Film Title Number #{name}",
          director: "Director #{name}",
        )
      end

      result = DailySummaryTweet.new(edition).text
      assert result.length <= 280, "Tweet was #{result.length} chars, expected ≤ 280"
      assert_match(/A VERY LONG FILM TITLE NUMBER/, result, "Expected at least one film line to survive truncation")
    end
  end

  test "#post! posts the tweet text to the X API" do
    travel_to Time.zone.local(2026, 5, 10, 23, 50, 0) do
      edition = editions(:base)
      premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

      expected_text = <<~TWEET.chomp
        TIFF24: May 10 Recap

        PREMIERE FILM (Smith): 3.00 from 4 ratings

        Check out all of our critics scores from the festival here: http://localhost:3000/editions/tiff24
      TWEET

      X::Client.any_instance.expects(:post).with("tweets", { text: expected_text }.to_json).returns(true)

      DailySummaryTweet.new(edition).post!
    end
  end
end
