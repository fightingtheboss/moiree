# frozen_string_literal: true

class SignInToken < ApplicationRecord
  belongs_to :user
end
