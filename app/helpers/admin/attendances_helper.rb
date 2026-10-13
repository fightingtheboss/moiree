# frozen_string_literal: true

module Admin::AttendancesHelper
  # Inherited ratings aren't counted: they come back if the critic is re-added
  def attendance_removal_confirmation(attendance)
    native_ratings_count = attendance.ratings.native.count
    return unless native_ratings_count.positive?

    edition_code = attendance.edition.code
    "Remove #{attendance.critic.name} from #{edition_code}? " \
      "This permanently deletes their #{pluralize(native_ratings_count, "rating")} at #{edition_code}."
  end
end
