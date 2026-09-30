# frozen_string_literal: true

namespace :transistor do
  desc "Import published episodes from Transistor.fm into the platform podcast"
  task import_episodes: :environment do
    Podcast.platform.first.import_transistor_episodes
  end
end
