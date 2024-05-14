# frozen_string_literal: true

class Festival < ApplicationRecord
  include Editionable
  include FriendlyId

  friendly_id :short_name, use: :slugged

  validates :name, :short_name, :url, :country, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "is not a valid URL" }
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }
end
