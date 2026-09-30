# frozen_string_literal: true

require "test_helper"

class SyncPodcastEpisodesJobTest < ActiveJob::TestCase
  test "imports Transistor episodes into the platform podcast" do
    Podcast.any_instance.expects(:import_transistor_episodes).once

    perform_enqueued_jobs { SyncPodcastEpisodesJob.perform_later }
  end
end
