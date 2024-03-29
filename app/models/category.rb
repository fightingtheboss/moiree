# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :edition

  has_many :categorizations, dependent: :destroy
  has_many :films, through: :categorizations
  has_many :ratings, through: :films

  validates :name, presence: true, uniqueness: { scope: :edition_id }

  # We could memoize this, but I don't think it will be heavily used
  # I'm also wary to add more side-effects to saving a Rating
  def overall_average_rating
    ratings.average(:score).to_f
  end
end
