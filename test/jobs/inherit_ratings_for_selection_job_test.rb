# frozen_string_literal: true

require "test_helper"

class InheritRatingsForSelectionJobTest < ActiveSupport::TestCase
  test "calls Rating.inherit_for for each critic attending the edition" do
    selection = selections(:base)
    critics = selection.edition.critics.to_a

    critics.each do |critic|
      Rating.expects(:inherit_for).with(critic:, selection:).once
    end

    InheritRatingsForSelectionJob.new.perform(selection)
  end

  test "creates inherited ratings for attending critics who have prior ratings for the film" do
    # critics(:base) has a native rating for films(:base) at editions(:base)
    # Create a new edition where critics(:base) is attending
    new_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "NEWSEL25",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "newsel25",
    )
    Attendance.create!(critic: critics(:base), edition: new_edition)
    category = Category.create!(edition: new_edition, name: "Main", position: 1)

    # Adding films(:base) to new_edition — critics(:base) should get an inherited rating
    new_selection = Selection.create!(edition: new_edition, film: films(:base), category: category)

    assert_difference "Rating.count", 1 do
      InheritRatingsForSelectionJob.new.perform(new_selection)
    end

    inherited = Rating.find_by(critic: critics(:base), selection: new_selection)
    assert_not_nil inherited
    assert_equal editions(:base).id, inherited.source_edition_id
  end
end
