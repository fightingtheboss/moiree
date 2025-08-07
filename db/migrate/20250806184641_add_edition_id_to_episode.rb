# frozen_string_literal: true

class AddEditionIdToEpisode < ActiveRecord::Migration[8.0]
  def change
    add_reference(:episodes, :edition, foreign_key: true)
  end
end
