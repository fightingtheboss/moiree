# frozen_string_literal: true

class AddUniqueIndexOnCriticIdAndSelectionIdToRatings < ActiveRecord::Migration[8.1]
  def change
    add_index(:ratings, [:critic_id, :selection_id], unique: true)
  end
end
