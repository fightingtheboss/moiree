# frozen_string_literal: true

module Festival::Editionable
  extend ActiveSupport::Concern

  included do
    has_many :editions, dependent: :destroy
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
