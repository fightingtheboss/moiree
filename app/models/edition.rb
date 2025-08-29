# frozen_string_literal: true

class Edition < ApplicationRecord
  include FriendlyId

  belongs_to :festival

  has_many :attendances, dependent: :destroy
  has_many :critics, through: :attendances

  has_many :categories, dependent: :destroy
  has_many :episodes, dependent: :destroy

  has_many :selections, dependent: :destroy
  has_many :films, through: :selections
  has_many :ratings, through: :selections

  has_one_attached :share_image

  validates :code, :year, :start_date, :end_date, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 2023 }
  validates :end_date, comparison: { greater_than: :start_date }

  delegate :name, :short_name, :country, to: :festival

  scope :upcoming, -> { includes(:festival).where("start_date > ?", Date.current).order(:start_date) }
  scope :past, -> { includes(:festival).where("end_date < ?", Date.current).order(start_date: :desc) }
  scope :current, -> {
                    includes(:festival)
                      .where("start_date <= ? AND end_date >= ?", Date.current, Date.current)
                      .order(:start_date)
                  }

  friendly_id :code, use: [:slugged, :scoped], scope: :festival

  after_create_commit :attach_fallback_share_image

  def url
    super || festival.url
  end

  def current?
    start_date <= Date.current && end_date >= Date.current
  end

  def current_day
    if current?
      (Date.current - start_date).to_i + 1
    end
  end

  def past?
    end_date + 1.day < Date.current
  end

  def summary?
    # TODO: Add a time zone to the edition model and use it to scope the date comparisons
    start_date <= Date.current
  end

  private

  def attach_fallback_share_image
    return if share_image.attached?

    FallbackEditionShareImageJob.perform_later(id)
  end
end
