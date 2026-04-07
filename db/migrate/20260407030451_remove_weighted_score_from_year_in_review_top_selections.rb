# frozen_string_literal: true

class RemoveWeightedScoreFromYearInReviewTopSelections < ActiveRecord::Migration[8.0]
  def change
    remove_column(:year_in_review_top_selections, :weighted_score, :decimal, precision: 10, scale: 6)
  end
end
