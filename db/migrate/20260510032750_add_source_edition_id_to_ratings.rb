# frozen_string_literal: true

class AddSourceEditionIdToRatings < ActiveRecord::Migration[7.2]
  def change
    add_reference :ratings, :source_edition, foreign_key: { to_table: :editions }, null: true
  end
end
