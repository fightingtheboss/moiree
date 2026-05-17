# frozen_string_literal: true

class AddWalkedOutToRatings < ActiveRecord::Migration[8.0]
  def change
    add_column :ratings, :walked_out, :boolean, default: false, null: false
  end
end
