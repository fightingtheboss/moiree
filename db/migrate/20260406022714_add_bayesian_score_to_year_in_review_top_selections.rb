# frozen_string_literal: true

class AddBayesianScoreToYearInReviewTopSelections < ActiveRecord::Migration[8.0]
  def change
    add_column(:year_in_review_top_selections, :bayesian_score, :decimal)
  end
end
