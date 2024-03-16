# frozen_string_literal: true

class Categorization < ApplicationRecord
  belongs_to :category
  belongs_to :film
end
