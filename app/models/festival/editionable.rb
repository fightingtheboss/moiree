# frozen_string_literal: true

module Festival::Editionable
  extend ActiveSupport::Concern

  included do
    has_many :editions, dependent: :destroy

    scope :upcoming, -> { joins(:editions).merge(Edition.upcoming).distinct }
    scope :past, -> { joins(:editions).merge(Edition.past).distinct }
    scope :current, -> { joins(:editions).merge(Edition.current).distinct }
  end

  def current_edition
    editions.current
  end

  def upcoming_editions
    editions.upcoming
  end

  def past_editions
    editions.past
  end
end
