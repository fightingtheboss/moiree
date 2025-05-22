# frozen_string_literal: true

class CreatePodcastEpisodes < ActiveRecord::Migration[8.0]
  def change
    create_table(:podcast_episodes) do |t|
      t.string(:title)
      t.text(:description)
      t.references(:podcast, null: false, foreign_key: true)
      t.string(:url)
      t.text(:embed)

      t.timestamps
    end
  end
end
