# frozen_string_literal: true

class Festival < ApplicationRecord
  validates :name, :short_name, :url, :code, :year, :country, :start_date, :end_date, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 2023 }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "is not a valid URL" }
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }
  validates :end_date, comparison: { greater_than: :start_date }

  class << self
    def current
      where("start_date <= ? AND end_date >= ?", Date.current, Date.current).first
    end

    def upcoming
      where("start_date > ?", Date.current).order(:start_date)
    end

    def past
      where("end_date < ?", Date.current).order(start_date: :desc)
    end
  end
end
