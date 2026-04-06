# frozen_string_literal: true

require "test_helper"

class YearInReviewTest < ActiveSupport::TestCase
  test "should not be valid without a year" do
    year_in_review = YearInReview.new

    assert_not(year_in_review.valid?)
    assert_includes(year_in_review.errors[:year], "can't be blank")
  end

  test "should not be valid with a duplicate year" do
    year_in_review = YearInReview.new(year: year_in_reviews(:base).year)

    assert_not(year_in_review.valid?)
    assert_includes(year_in_review.errors[:year], "has already been taken")
  end

  test "should not be valid with a year less than or equal to 2023" do
    year_in_review = YearInReview.new(year: 2023)

    assert_not(year_in_review.valid?)
  end

  test "should be valid with a unique year greater than 2023" do
    year_in_review = YearInReview.new(year: 2025)

    assert(year_in_review.valid?)
  end

  test "#editions returns editions within the year" do
    year_in_review = year_in_reviews(:base)
    edition = editions(:base)

    assert_includes(year_in_review.editions, edition)
  end

  test "#stale? returns true when generated_at is nil" do
    year_in_review = YearInReview.new(year: 2025)

    assert(year_in_review.stale?)
  end

  test "#stale? returns false when generated_at is recent and no editions updated" do
    year_in_review = year_in_reviews(:base)
    year_in_review.update!(generated_at: Time.current)

    assert_not(year_in_review.stale?)
  end

  test "#generate! populates stats from editions" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    assert_not_nil(year_in_review.generated_at)
    assert(year_in_review.editions_count >= 0)
    assert(year_in_review.critics_count >= 0)
    assert(year_in_review.films_count >= 0)
    assert(year_in_review.ratings_count >= 0)
  end

  test "#generate! with no editions sets zero counts" do
    year_in_review = YearInReview.create!(year: 2030)
    year_in_review.generate!

    assert_equal(0, year_in_review.editions_count)
    assert_equal(0, year_in_review.critics_count)
    assert_equal(0, year_in_review.films_count)
    assert_equal(0, year_in_review.ratings_count)
    assert_not_nil(year_in_review.generated_at)
  end

  test "#top_selections_with_includes returns YearInReviewTopSelection records with eager-loaded associations" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    top_selections = year_in_review.top_selections_with_includes

    assert_kind_of(ActiveRecord::Relation, top_selections)
    top_selections.each do |ts|
      assert_kind_of(YearInReviewTopSelection, ts)
    end
  end

  test "#generate! aggregates ratings across multiple editions for the same film" do
    # Create a second edition in the same year (2024) at a different festival
    second_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2024,
      code: "CANNES24",
      start_date: "2024-05-14",
      end_date: "2024-05-25",
      slug: "cannes24",
    )

    # Create a category for the second edition
    category = Category.create!(edition: second_edition, name: "Competition", position: 1)

    # The base film (year: 2024) already has a selection at editions(:base)
    film = films(:base)

    # Create a second selection for the same film at the second edition
    second_selection = Selection.create!(edition: second_edition, film: film, category: category)

    # Create attendance records for critics at both editions
    Attendance.create!(critic: critics(:without_publication), edition: second_edition)
    Attendance.create!(critic: critics(:without_ratings), edition: second_edition)

    # Existing ratings on base selection: base (3.5), without_publication (2.5),
    #   frequent_rater (1.0), contrarian (1.5) = 4 ratings
    # Add two more ratings on the SECOND selection for cross-edition aggregation
    Rating.create!(
      critic: critics(:without_publication),
      selection: second_selection,
      score: 4.0,
      skip_cache_average_ratings_callback: true,
    )
    Rating.create!(
      critic: critics(:without_ratings),
      selection: second_selection,
      score: 5.0,
      skip_cache_average_ratings_callback: true,
    )

    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    top = year_in_review.top_selections_with_includes.to_a
    top_for_film = top.find { |ts| ts.selection.film_id == film.id }

    assert_not_nil(top_for_film, "Film should appear in top selections via cross-edition aggregation")
    # Total: 6 ratings (3.5 + 2.5 + 1.0 + 1.5 + 4.0 + 5.0) = 17.5 / 6 ≈ 2.917
    assert_equal(6, top_for_film.combined_ratings_count)
    assert_in_delta(2.917, top_for_film.combined_average_rating.to_f, 0.01)
    assert_not_nil(top_for_film.bayesian_score, "Bayesian score should be stored")
  end

  test "has many top_selections through year_in_review_top_selections" do
    year_in_review = year_in_reviews(:base)

    assert_respond_to(year_in_review, :top_selections)
    assert_respond_to(year_in_review, :year_in_review_top_selections)
  end

  test "#bombe_moiree_histogram returns empty hash when no bombe moiree" do
    year_in_review = YearInReview.new(year: 2030)

    assert_equal({}, year_in_review.bombe_moiree_histogram)
  end

  test "#most_divisive_histogram returns empty hash when no most divisive" do
    year_in_review = YearInReview.new(year: 2030)

    assert_equal({}, year_in_review.most_divisive_histogram)
  end

  test ".for returns a generated YearInReview for the given year" do
    year_in_review = YearInReview.for(year_in_reviews(:base).year)

    assert_kind_of(YearInReview, year_in_review)
    assert_not_nil(year_in_review.generated_at)
    assert(year_in_review.persisted?)
  end

  test ".for creates a new record if one does not exist" do
    assert_difference("YearInReview.count", 1) do
      YearInReview.for(2029)
    end
  end

  test ".for returns existing record without regenerating if fresh" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!
    original_generated_at = year_in_review.generated_at

    result = YearInReview.for(year_in_review.year)

    assert_equal(original_generated_at, result.generated_at)
  end

  test ".current returns a YearInReview for the current year" do
    year_in_review = YearInReview.current

    assert_kind_of(YearInReview, year_in_review)
    assert_equal(Date.current.year, year_in_review.year)
    assert_not_nil(year_in_review.generated_at)
  end

  test "includes Summarizable concern" do
    assert_includes(YearInReview.ancestors, Summarizable)
  end

  test "#summary_selections returns selections across all editions in the year" do
    year_in_review = year_in_reviews(:base)

    edition_ids = Edition.within(year_in_review.year).pluck(:id)
    expected = Selection.where(edition_id: edition_ids).order(:id).to_a

    assert_equal(expected, year_in_review.summary_selections.order(:id).to_a)
  end

  test "#generate! uses Summarizable methods for bombe_moiree and most_divisive" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    # Fixtures have 4 ratings per selection, meeting the dynamic threshold
    # (1 attending critic → ceil(1/3) = 1 → floor of 4 applies)
    assert_equal(
      selections(:base),
      year_in_review.bombe_moiree_selection,
      "Base selection (avg 3.5) should be bombe moirée",
    )
    assert_equal(
      selections(:with_original_title),
      year_in_review.most_divisive_selection,
      "With original title (scores 4.5, 0.0, 5.0, 1.0) should be most divisive",
    )
  end

  test "#five_star_ratings delegates to Summarizable" do
    year_in_review = year_in_reviews(:base)

    assert_equal(1, year_in_review.five_star_ratings.size)
    assert(year_in_review.five_star_ratings.all? { |r| r.score == 5.0 })
  end

  test "#zero_star_ratings delegates to Summarizable" do
    year_in_review = year_in_reviews(:base)

    assert_equal(1, year_in_review.zero_star_ratings.size)
    assert(year_in_review.zero_star_ratings.all? { |r| r.score == 0.0 })
  end

  test "#bombe_moiree_histogram uses cached bombe_moiree_selection" do
    year_in_review = year_in_reviews(:base)
    year_in_review.update!(bombe_moiree_selection: nil)

    assert_equal({}, year_in_review.bombe_moiree_histogram)
  end

  test "#most_divisive_histogram uses cached most_divisive_selection" do
    year_in_review = year_in_reviews(:base)
    year_in_review.update!(most_divisive_selection: nil)

    assert_equal({}, year_in_review.most_divisive_histogram)
  end

  test "#summary_critics_count returns distinct attending critics across all editions in the year" do
    year_in_review = year_in_reviews(:base)

    expected = Attendance.where(
      edition_id: Edition.within(year_in_review.year).select(:id),
    ).distinct.count(:critic_id)

    assert_equal(expected, year_in_review.summary_critics_count)
  end

  test "#min_ratings_for_summary uses floor of 4 for small critic pools" do
    year_in_review = year_in_reviews(:base)

    # 1 attending critic → ceil(1/3) = 1 → max(1, 4) = 4
    assert_equal(4, year_in_review.min_ratings_for_summary)
  end

  test "#min_ratings_for_summary scales to 1/3 of critic pool when above floor" do
    year_in_review = year_in_reviews(:base)
    edition = editions(:base)

    # Add 17 more critics (18 total attending) → ceil(18/3) = 6 > 4
    17.times do |i|
      critic = Critic.create!(first_name: "YIR#{i}", last_name: "Test", country: "US")
      Attendance.create!(critic: critic, edition: edition)
    end

    assert_equal(6, year_in_review.min_ratings_for_summary)
  end

  test "#generate! ranks films with small critic pools using bayesian weighting" do
    # Create two editions in 2026: one large, one small
    large_edition = Edition.create!(
      festival: festivals(:base), year: 2026, code: "LARGE26",
      start_date: "2026-06-01", end_date: "2026-06-10", slug: "large26",
    )
    small_edition = Edition.create!(
      festival: festivals(:with_no_films), year: 2026, code: "SMALL26",
      start_date: "2026-09-01", end_date: "2026-09-10", slug: "small26",
    )

    large_category = Category.create!(edition: large_edition, name: "Main", position: 1)
    small_category = Category.create!(edition: small_edition, name: "Main", position: 1)

    # A mediocre film at the large edition with many ratings
    mediocre_film = Film.create!(
      title: "Mediocre Film", normalized_title: "Mediocre Film",
      director: "Director A", country: "US", year: 2026,
    )
    mediocre_selection = Selection.create!(
      edition: large_edition, film: mediocre_film, category: large_category,
      average_rating: 3.0,
    )

    # An excellent film at the small edition with few ratings
    excellent_film = Film.create!(
      title: "Excellent Film", normalized_title: "Excellent Film",
      director: "Director B", country: "FR", year: 2026,
    )
    excellent_selection = Selection.create!(
      edition: small_edition, film: excellent_film, category: small_category,
      average_rating: 5.0,
    )

    # Create 20 critics at the large edition, each rating the mediocre film 3.0
    20.times do |i|
      critic = Critic.create!(first_name: "Large#{i}", last_name: "Critic", country: "US")
      Attendance.create!(critic: critic, edition: large_edition)
      Rating.create!(critic: critic, selection: mediocre_selection, score: 3.0,
        skip_cache_average_ratings_callback: true)
    end

    # Create 3 critics at the small edition, each rating the excellent film 5.0
    3.times do |i|
      critic = Critic.create!(first_name: "Small#{i}", last_name: "Critic", country: "FR")
      Attendance.create!(critic: critic, edition: small_edition)
      Rating.create!(critic: critic, selection: excellent_selection, score: 5.0,
        skip_cache_average_ratings_callback: true)
    end

    year_in_review = YearInReview.create!(year: 2026)
    year_in_review.generate!

    top = year_in_review.top_selections_with_includes.to_a
    film_ids = top.map { |ts| ts.selection.film_id }

    assert_includes(film_ids, excellent_film.id,
      "Highly-rated film from small edition should appear in top selections")

    excellent_entry = top.find { |ts| ts.selection.film_id == excellent_film.id }
    mediocre_entry = top.find { |ts| ts.selection.film_id == mediocre_film.id }

    assert_operator(excellent_entry.bayesian_score, :>, mediocre_entry.bayesian_score,
      "Excellent film with few ratings should rank above mediocre film with many ratings")
  end

  test "#generate! includes films that would have fallen below the old min_ratings threshold" do
    # Create an edition in 2027 with 12 attending critics (old threshold: ceil(12/3)=4)
    edition = Edition.create!(
      festival: festivals(:base), year: 2027, code: "TEST27",
      start_date: "2027-06-01", end_date: "2027-06-10", slug: "test27",
    )
    category = Category.create!(edition: edition, name: "Main", position: 1)

    # Create 12 attending critics
    created_critics = 12.times.map do |i|
      critic = Critic.create!(first_name: "Critic#{i}", last_name: "Pool", country: "US")
      Attendance.create!(critic: critic, edition: edition)
      critic
    end

    # Film A: 2 ratings (below old threshold of 4), both perfect 5.0
    film_a = Film.create!(
      title: "Hidden Gem", normalized_title: "Hidden Gem",
      director: "Director A", country: "US", year: 2027,
    )
    selection_a = Selection.create!(edition: edition, film: film_a, category: category, average_rating: 5.0)
    created_critics[0..1].each do |critic|
      Rating.create!(critic: critic, selection: selection_a, score: 5.0,
        skip_cache_average_ratings_callback: true)
    end

    # Film B: 6 ratings (above old threshold), average 3.0
    film_b = Film.create!(
      title: "Common Film", normalized_title: "Common Film",
      director: "Director B", country: "US", year: 2027,
    )
    selection_b = Selection.create!(edition: edition, film: film_b, category: category, average_rating: 3.0)
    created_critics[0..5].each do |critic|
      Rating.create!(critic: critic, selection: selection_b, score: 3.0,
        skip_cache_average_ratings_callback: true)
    end

    year_in_review = YearInReview.create!(year: 2027)
    year_in_review.generate!

    top = year_in_review.top_selections_with_includes.to_a
    film_ids = top.map { |ts| ts.selection.film_id }

    assert_includes(film_ids, film_a.id,
      "Film with only 2 ratings should now be included (previously excluded by hard threshold)")
  end

  test "#generate! stores bayesian_score on top selections" do
    year_in_review = year_in_reviews(:base)
    year_in_review.generate!

    top = year_in_review.top_selections_with_includes.to_a
    assert(top.all? { |ts| ts.bayesian_score.present? },
      "All top selections should have a bayesian_score")
  end
end
