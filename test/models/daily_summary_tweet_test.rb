# frozen_string_literal: true

require "test_helper"

class DailySummaryTweetTest < ActiveSupport::TestCase
  def premiere_selection(edition:, title:, director:, num_ratings: 4, score: 3.0)
    film = Film.create!(title: title, director: director, country: "FR", year: 2026)
    selection = Selection.create!(edition: edition, film: film, category: categories(:base))
    [critics(:base), critics(:without_publication), critics(:without_ratings), critics(:frequent_rater)]
      .first(num_ratings)
      .each do |critic|
        Attendance.find_or_create_by!(critic: critic, edition: edition)
        Rating.create!(selection: selection, critic: critic, score: score, created_at: 1.hour.ago)
      end
    selection.cache_average_rating
    selection
  end

  test "#premiere_selections returns selections with first rating in last 24h and at least 4 ratings" do
    edition = editions(:base)
    selection = premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

    assert_includes DailySummaryTweet.new(edition).premiere_selections, selection
  end

  test "#premiere_selections excludes selections with fewer than 4 ratings" do
    edition = editions(:base)
    selection = premiere_selection(edition: edition, title: "Few Ratings Film", director: "Jane Smith", num_ratings: 3)

    refute_includes DailySummaryTweet.new(edition).premiere_selections, selection
  end

  test "#premiere_selections excludes selections whose first rating was more than 24h ago" do
    edition = editions(:base)
    # selections(:base) has ratings from 1.week.ago — not a premiere
    refute_includes DailySummaryTweet.new(edition).premiere_selections, selections(:base)
  end

  test "#text returns the formatted premiere tweet" do
    travel_to Time.zone.local(2026, 5, 7) do
      edition = editions(:base)
      premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

      expected = <<~TWEET.chomp
        TIFF24: May 7 Recap

        PREMIERE FILM (Smith): 3.00 from 4 ratings

        Check out all of our critics scores from the festival here: http://localhost:3000/editions/tiff24
      TWEET

      assert_equal expected, DailySummaryTweet.new(edition).text
    end
  end

  test "#text truncates the film list when tweet exceeds 280 characters" do
    travel_to Time.zone.local(2026, 5, 7) do
      edition = editions(:base)
      ["Alpha", "Beta", "Gamma", "Delta"].each do |name|
        premiere_selection(
          edition: edition,
          title: "A Very Long Film Title Number #{name}",
          director: "Director #{name}",
        )
      end

      result = DailySummaryTweet.new(edition).text
      assert result.chars.size <= 280, "Tweet was #{result.chars.size} chars, expected ≤ 280"
      assert_match(/A VERY LONG FILM TITLE NUMBER/, result, "Expected at least one film line to survive truncation")
    end
  end

  test "#post! posts the tweet text to the X API" do
    travel_to Time.zone.local(2026, 5, 7) do
      edition = editions(:base)
      premiere_selection(edition: edition, title: "Premiere Film", director: "Jane Smith")

      expected_text = <<~TWEET.chomp
        TIFF24: May 7 Recap

        PREMIERE FILM (Smith): 3.00 from 4 ratings

        Check out all of our critics scores from the festival here: http://localhost:3000/editions/tiff24
      TWEET

      X::Client.any_instance.expects(:post).with("tweets", { text: expected_text }.to_json).returns(true)

      DailySummaryTweet.new(edition).post!
    end
  end
end
