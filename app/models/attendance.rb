# frozen_string_literal: true

class Attendance < ApplicationRecord
  belongs_to :critic, touch: true
  belongs_to :edition, touch: true

  validates :critic_id, uniqueness: { scope: :edition_id }

  after_commit :enqueue_inherit_ratings, on: :create
  before_destroy :destroy_ratings

  def ratings
    Rating.where(critic:, selection: edition.selections)
  end

  private

  def enqueue_inherit_ratings
    InheritRatingsForAttendanceJob.perform_later(self)
  end

  # Each destroyed rating recomputes its selection's and film's averages
  def destroy_ratings
    ratings.destroy_all
  end
end
