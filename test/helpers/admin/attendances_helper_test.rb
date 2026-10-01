# frozen_string_literal: true

require "test_helper"

class Admin::AttendancesHelperTest < ActionView::TestCase
  test "#attendance_removal_confirmation warns how many ratings removing the critic deletes" do
    # critics(:base) has 2 native ratings at editions(:base)
    assert_equal(
      "Remove #{critics(:base).name} from TIFF24? This permanently deletes their 2 ratings at TIFF24.",
      attendance_removal_confirmation(attendances(:base)),
    )
  end

  test "#attendance_removal_confirmation ignores inherited ratings" do
    attendance = attendances(:base)
    attendance.ratings.update_all(source_edition_id: editions(:with_no_films).id)

    assert_nil(attendance_removal_confirmation(attendance))
  end

  test "#attendance_removal_confirmation returns nil when the critic has no ratings at the edition" do
    attendance = Attendance.create!(critic: critics(:unaffiliated), edition: editions(:base))

    assert_nil(attendance_removal_confirmation(attendance))
  end
end
