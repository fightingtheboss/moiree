# frozen_string_literal: true

module Critic::Attendee
  extend ActiveSupport::Concern

  included do
    has_many :attendances, dependent: :destroy
    has_many :editions, through: :attendances do
      def current
        where("editions.start_date <= ? AND editions.end_date >= ?", Date.current, Date.current)
      end

      def past
        where("editions.end_date < ?", Date.current)
      end

      def upcoming
        where("editions.start_date > ?", Date.current)
      end
    end

    accepts_nested_attributes_for :attendances
  end

  def attending?(edition:)
    attendances.exists?(edition: edition)
  end

  def publication_for(edition:)
    attendances.find_by(edition: edition)&.publication || publication
  end

  def has_custom_publication?(edition:)
    publication != publication_for(edition: edition)
  end
end
