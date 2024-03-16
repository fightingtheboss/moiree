# frozen_string_literal: true

class Selection < ApplicationRecord
  belongs_to :edition
  belongs_to :film

  has_one :rating, dependent: :destroy
end
