# frozen_string_literal: true

require "test_helper"

class InheritRatingsForAttendanceJobTest < ActiveSupport::TestCase
  test "calls Rating.inherit_for for each selection in the edition" do
    attendance = attendances(:base)
    selections = attendance.edition.selections.to_a

    selections.each do |selection|
      Rating.expects(:inherit_for).with(critic: attendance.critic, selection: selection).once
    end

    InheritRatingsForAttendanceJob.new.perform(attendance)
  end

  test "creates inherited ratings for films the critic has previously rated" do
    # critics(:base) has ratings(:base) at editions(:base) for films(:base)
    # Create a new edition+selection for the same film
    new_edition = Edition.create!(
      festival: festivals(:with_no_films),
      year: 2025,
      code: "NEWATT25",
      start_date: "2025-06-01",
      end_date: "2025-06-10",
      slug: "newatt25",
    )
    category = Category.create!(edition: new_edition, name: "Main", position: 1)
    new_selection = Selection.create!(edition: new_edition, film: films(:base), category: category)

    new_attendance = Attendance.create!(
      critic: critics(:base),
      edition: new_edition,
    )

    assert_difference "Rating.count", 1 do
      InheritRatingsForAttendanceJob.new.perform(new_attendance)
    end

    inherited = Rating.find_by(critic: critics(:base), selection: new_selection)
    assert_not_nil inherited
    assert_equal editions(:base).id, inherited.source_edition_id
  end
end
