# frozen_string_literal: true

class AddSlugToPodcastEpisodes < ActiveRecord::Migration[8.0]
  def change
    add_column(:podcast_episodes, :slug, :string)
    add_index(:podcast_episodes, :slug, unique: true)
  end
end
