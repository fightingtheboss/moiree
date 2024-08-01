# frozen_string_literal: true

module Critic::Attendee
  extend ActiveSupport::Concern

  included do
    has_many :attendances, dependent: :destroy
    accepts_nested_attributes_for :attendances
  end

  def publication_for(edition:)
    attendances.find_by(edition: edition)&.publication || publication
  end

  def has_custom_publication?(edition:)
    publication != publication_for(edition: edition)
  end
end
