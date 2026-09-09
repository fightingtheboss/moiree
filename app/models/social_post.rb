# frozen_string_literal: true

class SocialPost < ApplicationRecord
  STATUSES = ["pending", "posted", "failed"].freeze

  belongs_to :edition
  has_many_attached :images

  validates :content_type, presence: true
  validates :platform, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :posted, -> { where(status: "posted") }
end
