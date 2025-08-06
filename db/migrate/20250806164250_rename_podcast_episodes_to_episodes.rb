# frozen_string_literal: true

class RenamePodcastEpisodesToEpisodes < ActiveRecord::Migration[8.0]
  def change
    rename_table :podcast_episodes, :episodes
  end
end
