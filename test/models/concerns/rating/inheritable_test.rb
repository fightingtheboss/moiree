# frozen_string_literal: true

require "test_helper"

class Rating::InheritableTest < ActiveSupport::TestCase
  test "Rating.native returns ratings where source_edition_id is nil" do
    native = ratings(:base) # source_edition_id: nil
    inherited = ratings(:without_publication)
    inherited.update_columns(source_edition_id: editions(:with_no_films).id)

    assert_includes Rating.native, native
    assert_not_includes Rating.native, inherited
  end

  test "Rating.native excludes ratings with a source_edition_id" do
    ratings(:base).update_columns(source_edition_id: editions(:with_no_films).id)

    assert_not_includes Rating.native, ratings(:base)
  end

  test "source_edition association returns the source Edition" do
    rating = ratings(:base)
    rating.update_columns(source_edition_id: editions(:with_no_films).id)

    assert_equal editions(:with_no_films), rating.source_edition
  end

  test "source_edition is nil when source_edition_id is nil" do
    assert_nil ratings(:base).source_edition
  end

  # --- inherit_for ---

  test "Rating.inherit_for does nothing when a rating already exists for that critic+selection" do
    # ratings(:base) already exists for critics(:base) + selections(:base)
    assert_no_difference "Rating.count" do
      Rating.inherit_for(critic: critics(:base), selection: selections(:base))
    end
  end

  test "Rating.inherit_for does nothing when critic has no prior native rating for the film" do
    assert_no_difference "Rating.count" do
      Rating.inherit_for(critic: critics(:without_ratings), selection: selections(:base))
    end
  end

  test "Rating.inherit_for creates an inherited rating copying score, impression, review_url" do
    source = ratings(:base) # critic: base, selection: base (film: base)

    # Create a second edition with the same film
    second_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "TEST25",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "test25",
    )
    category = Category.create!(edition: second_edition, name: "Main", position: 1)
    new_selection = Selection.create!(edition: second_edition, film: films(:base), category: category)

    assert_difference "Rating.count", 1 do
      Rating.inherit_for(critic: critics(:base), selection: new_selection)
    end

    inherited = Rating.find_by(critic: critics(:base), selection: new_selection)
    assert_equal source.score, inherited.score
    assert_nil inherited.review_url
    assert_nil inherited.impression
  end

  test "Rating.inherit_for sets source_edition_id to the source rating's edition" do
    second_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "TEST25B",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "test25b",
    )
    category = Category.create!(edition: second_edition, name: "Main", position: 1)
    new_selection = Selection.create!(edition: second_edition, film: films(:base), category: category)

    Rating.inherit_for(critic: critics(:base), selection: new_selection)

    inherited = Rating.find_by(critic: critics(:base), selection: new_selection)
    # ratings(:base) is native (source_edition_id nil), so inherited points to its edition
    assert_equal editions(:base).id, inherited.source_edition_id
  end

  test "Rating.inherit_for preserves existing source_edition_id when source is itself inherited" do
    # Simulate: critic rated at edition A (native), inherited to edition B,
    # now being inherited again to edition C — should still point to edition A.
    ultimate_source = editions(:base)

    second_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "TEST25C",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "test25c",
    )
    category_b = Category.create!(edition: second_edition, name: "Main", position: 1)
    selection_b = Selection.create!(edition: second_edition, film: films(:base), category: category_b)

    # Place an inherited rating at edition B pointing back to edition A
    Rating.create!(
      critic: critics(:without_ratings),
      selection: selection_b,
      score: 4.0,
      source_edition_id: ultimate_source.id,
      skip_cache_average_ratings_callback: true,
    )

    third_edition = Edition.create!(
      festival: festivals(:base),
      year: 2025,
      code: "TEST25D",
      start_date: "2025-08-01",
      end_date: "2025-08-10",
      slug: "test25d",
    )
    category_c = Category.create!(edition: third_edition, name: "Main", position: 1)
    selection_c = Selection.create!(edition: third_edition, film: films(:base), category: category_c)

    # inherit_for should skip rating_b (it's inherited) and find no native rating for this critic
    # so nothing is created — critics(:without_ratings) has no native rating for films(:base)
    assert_no_difference "Rating.count" do
      Rating.inherit_for(critic: critics(:without_ratings), selection: selection_c)
    end
  end

  test "Rating.inherit_for does not enqueue CacheAverageRatingJob" do
    second_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "TEST25E",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "test25e",
    )
    category = Category.create!(edition: second_edition, name: "Main", position: 1)
    new_selection = Selection.create!(edition: second_edition, film: films(:base), category: category)

    CacheAverageRatingJob.expects(:perform_later).never

    Rating.inherit_for(critic: critics(:base), selection: new_selection)
  end

  test "Rating.inherit_for preserves walked_out status from the source rating" do
    critic = critics(:without_ratings)
    source_selection = selections(:base)
    Rating.create!(
      critic:,
      selection: source_selection,
      score: 5.0,
      walked_out: true,
      skip_cache_average_ratings_callback: true,
    )

    second_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "WALKOUT25",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "walkout25",
    )
    category = Category.create!(edition: second_edition, name: "Main", position: 1)
    new_selection = Selection.create!(edition: second_edition, film: films(:base), category:)

    Rating.inherit_for(critic:, selection: new_selection)

    inherited = Rating.find_by(critic:, selection: new_selection)
    assert inherited.walked_out?
    assert_equal 0.0, inherited.score.to_f
  end

  test "Rating.inherit_for picks the most recent native rating when critic has multiple" do
    # ratings(:base) is for critics(:base) at editions(:base) (end_date: 2024-09-19)
    # Create a second native rating for the same critic+film at a later edition
    later_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "LATER25",
      start_date: "2025-01-01",
      end_date: "2025-01-10",
      slug: "later25",
    )
    later_category = Category.create!(edition: later_edition, name: "Main", position: 1)
    later_selection = Selection.create!(edition: later_edition, film: films(:base), category: later_category)
    Rating.create!(
      critic: critics(:base),
      selection: later_selection,
      score: 1.5,
      skip_cache_average_ratings_callback: true,
    )

    # Now inherit into a third edition — should pick later_rating (score 1.5)
    third_edition = Edition.create!(
      festival: festivals(:base),
      year: 2025,
      code: "THIRD25",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "third25",
    )
    third_category = Category.create!(edition: third_edition, name: "Main", position: 1)
    third_selection = Selection.create!(edition: third_edition, film: films(:base), category: third_category)

    Rating.inherit_for(critic: critics(:base), selection: third_selection)

    inherited = Rating.find_by(critic: critics(:base), selection: third_selection)
    assert_equal 1.5, inherited.score
    assert_equal later_edition.id, inherited.source_edition_id
  end
end
