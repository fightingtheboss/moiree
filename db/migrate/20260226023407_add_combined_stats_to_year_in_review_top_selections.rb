# frozen_string_literal: true

class AddCombinedStatsToYearInReviewTopSelections < ActiveRecord::Migration[8.0]
  def change
    add_column(:year_in_review_top_selections, :combined_average_rating, :decimal)
    add_column(:year_in_review_top_selections, :combined_ratings_count, :integer)
  end
end
