# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user_agent, :ip_address

  delegate :user, to: :session, allow_nil: true

  class << self
    def critic_for?(edition:)
      user.critic? && user.userable.editions.include?(edition)
    end
  end
end
