# frozen_string_literal: true

class InheritRatingsForAttendanceJob < ApplicationJob
  queue_as :default

  def perform(attendance)
    attendance.edition.selections.each do |selection|
      Rating.inherit_for(critic: attendance.critic, selection:)
    end

    attendance.edition.cache_average_ratings
  end
end
