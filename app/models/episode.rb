# frozen_string_literal: true

class Episode < ApplicationRecord
  include FriendlyId

  belongs_to :podcast

  validates :title, :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(["https"]) }

  friendly_id :slug_candidates, use: :slugged

  private

  def slug_candidates
    [
      :title,
      [:title, -> { podcast.title }],
      [:title, -> { podcast.title }, -> { Time.current.to_i }],
    ]
  end
end
