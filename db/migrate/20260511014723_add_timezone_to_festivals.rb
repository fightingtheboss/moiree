# frozen_string_literal: true

class AddTimezoneToFestivals < ActiveRecord::Migration[8.0]
  def change
    add_column(:festivals, :timezone, :string, null: false, default: "UTC")
  end
end
