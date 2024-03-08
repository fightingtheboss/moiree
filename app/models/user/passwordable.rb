# frozen_string_literal: true

module User::Passwordable
  extend ActiveSupport::Concern

  included do
    has_secure_password

    validates :password, allow_nil: true, length: { minimum: 12 }

    generates_token_for :password_reset, expires_in: 20.minutes do
      password_salt.last(10)
    end

    after_update if: :password_digest_previously_changed? do
      sessions.where.not(id: Current.session).delete_all
    end
  end
end
