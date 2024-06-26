# frozen_string_literal: true

class Attendance < ApplicationRecord
  belongs_to :critic
  belongs_to :edition, touch: true

  validates :critic_id, uniqueness: { scope: :edition_id }
end
