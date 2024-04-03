# frozen_string_literal: true

class Categorization < ApplicationRecord
  belongs_to :category, inverse_of: :categorizations
  belongs_to :film, inverse_of: :categorizations

  validates :category_id, uniqueness: { scope: :film_id }

  accepts_nested_attributes_for :category
end
