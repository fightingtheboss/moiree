# frozen_string_literal: true

class Selection < ApplicationRecord
  belongs_to :edition, inverse_of: :selections
  belongs_to :film, inverse_of: :selections

  has_one :rating, dependent: :destroy

  validates :edition_id, uniqueness: { scope: :film_id }
end
