class User < ApplicationRecord
  include Passwordable, Verifiable

  has_many :sessions, dependent: :destroy
  has_many :sign_in_tokens, dependent: :destroy

  delegated_type :userable, types: %w[ Admin, Critic ]
  delegate :name, :initials, to: :userable

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: -> { _1.strip.downcase }

  accepts_nested_attributes_for :userable
end
