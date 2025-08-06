# frozen_string_literal: true

class Podcast < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  belongs_to :user
  has_many :episodes, dependent: :destroy, class_name: "Podcast::Episode"

  validates :title, :slug, presence: true

  accepts_nested_attributes_for(:episodes, allow_destroy: true)

  scope :platform, -> { where(platform: true) }

  private

  def slug_candidates
    [
      :title,
      [:title, -> { user&.name }],
    ]
  end
end
