# frozen_string_literal: true

class SyncPodcastEpisodesJob < ApplicationJob
  queue_as :default

  def perform
    Podcast.platform.first.import_transistor_episodes
  end
end
