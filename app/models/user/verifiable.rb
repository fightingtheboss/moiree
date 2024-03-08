# frozen_string_literal: true

module User::Verifiable
  extend ActiveSupport::Concern

  included do
    generates_token_for :email_verification, expires_in: 2.days do
      email
    end

    before_validation if: :email_changed?, on: :update do
      self.verified = false
    end
  end
end
