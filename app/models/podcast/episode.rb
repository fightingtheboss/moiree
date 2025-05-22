# frozen_string_literal: true

class Podcast::Episode < ApplicationRecord
  self.table_name = "podcast_episodes"

  belongs_to :podcast

  validates :title, :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(["https"]) }
end
