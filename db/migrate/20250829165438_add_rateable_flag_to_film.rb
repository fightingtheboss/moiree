# frozen_string_literal: true

class AddRateableFlagToFilm < ActiveRecord::Migration[8.0]
  def change
    add_column(:films, :rateable, :boolean, default: true, null: false)
  end
end
