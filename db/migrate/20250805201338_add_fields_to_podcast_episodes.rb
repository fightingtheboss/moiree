# frozen_string_literal: true

class AddFieldsToPodcastEpisodes < ActiveRecord::Migration[8.0]
  def change
    add_column(:podcast_episodes, :summary, :text)
    add_column(:podcast_episodes, :published_at, :datetime)
    add_column(:podcast_episodes, :duration, :integer)

    add_index(:podcast_episodes, :published_at)
  end
end
