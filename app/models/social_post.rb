# frozen_string_literal: true

class SocialPost < ApplicationRecord
  STATUSES = ["pending", "posted", "failed"].freeze

  belongs_to :edition
  has_many_attached :images

  validates :content_type, inclusion: { in: -> { PublishCarouselJob::CONTENT_TYPES.keys } }
  validates :platform, inclusion: { in: -> { PublishCarouselJob::PUBLISHERS.keys } }
  validates :status, inclusion: { in: STATUSES }

  scope :posted, -> { where(status: "posted") }
end
