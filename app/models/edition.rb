# frozen_string_literal: true

class Edition < ApplicationRecord
  belongs_to :festival

  validates :code, :year, :start_date, :end_date, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 2023 }
  validates :end_date, comparison: { greater_than: :start_date }

  delegate :name, :short_name, :country, to: :festival

  scope :upcoming, -> { where("start_date >= ?", Date.current).order(:start_date) }
  scope :past, -> { where("end_date < ?", Date.current).order(start_date: :desc) }

  class << self
    def current
      where("start_date <= ? AND end_date >= ?", Date.current, Date.current).first
    end
  end

  def url
    super || festival.url
  end
end
