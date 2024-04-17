# frozen_string_literal: true

module Userable
  extend ActiveSupport::Concern

  included do
    has_one :user, as: :userable, touch: true, dependent: :destroy

    delegate :email, to: :user
  end
end
