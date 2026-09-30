# frozen_string_literal: true

require "test_helper"

class Podcasts::EpisodesControllerTest < ActionDispatch::IntegrationTest
  test "show renders the episode" do
    podcast = podcasts(:base)
    episode = podcast.episodes.create!(title: "TIFF 2026 Round Table #3", url: "https://share.transistor.fm/s/5b2b5c43")

    get podcast_episode_path(podcast, episode)

    assert_response(:success)
    assert_match("TIFF 2026 Round Table #3", response.body)
  end

  test "show responds with not found for an unknown episode" do
    get podcast_episode_path(podcasts(:base), "missing-episode")

    assert_response(:not_found)
  end
end
