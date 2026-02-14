# frozen_string_literal: true

class YearInReviewTopSelection < ApplicationRecord
  belongs_to :year_in_review, inverse_of: :year_in_review_top_selections
  belongs_to :selection

  validates :position, presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :year_in_review_id }
  validates :selection_id, uniqueness: { scope: :year_in_review_id }
end
