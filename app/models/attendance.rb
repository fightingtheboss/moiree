# frozen_string_literal: true

class Attendance < ApplicationRecord
  belongs_to :critic, touch: true
  belongs_to :edition, touch: true

  validates :critic_id, uniqueness: { scope: :edition_id }

  after_commit :enqueue_inherit_ratings, on: :create
  before_destroy :destroy_inherited_ratings

  private

  def enqueue_inherit_ratings
    InheritRatingsForAttendanceJob.perform_later(self)
  end

  def destroy_inherited_ratings
    Rating.where(critic:, selection: edition.selections).where.not(source_edition_id: nil).destroy_all
  end
end
