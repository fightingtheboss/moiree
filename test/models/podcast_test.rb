# frozen_string_literal: true

require "test_helper"

class PodcastTest < ActiveSupport::TestCase
  setup do
    @critic = users(:critic)
    @podcast = Podcast.new(title: "Test Podcast", user: @critic)
  end

  test "should be valid" do
    assert @podcast.valid?
  end

  test "title should be present" do
    @podcast.title = nil
    assert_not @podcast.valid?
  end

  test "slug should be generated from title" do
    @podcast.save
    assert_equal "test-podcast", @podcast.slug
  end

  test "slug should include critic name when title is not unique" do
    @podcast.save
    duplicate_podcast = Podcast.new(title: "Test Podcast", user: users(:admin))
    duplicate_podcast.save
    assert_match(/test-podcast-.*/, duplicate_podcast.slug)
  end

  test "should belong to a user" do
    @podcast.user = nil
    assert_not @podcast.valid?
  end

  test "should use friendly id" do
    @podcast.save
    assert_equal @podcast, Podcast.friendly.find("test-podcast")
  end

  test "import_transistor_episodes creates episodes that have not been imported" do
    podcast = podcasts(:with_platform)
    Transistor.expects(:published_episodes).with(Podcast::TRANSISTOR_SHOW_ID).returns([transistor_episode])

    assert_difference -> { podcast.episodes.count }, 1 do
      podcast.import_transistor_episodes
    end

    episode = podcast.episodes.find_by!(provider_id: "3586072")

    assert_equal "TIFF 2026 Round Table #3", episode.title
    assert_equal "<p>Summary</p>", episode.summary
    assert_equal "<p>Description</p>", episode.description
    assert_equal "https://share.transistor.fm/s/5b2b5c43", episode.url
    assert_equal "<iframe></iframe>", episode.embed
    assert_equal "tiff-2026-round-table-3", episode.slug
    assert_equal Time.utc(2026, 9, 21, 2, 29, 36), episode.published_at
    assert_equal 4400, episode.duration
  end

  test "import_transistor_episodes leaves previously imported episodes untouched" do
    podcast = podcasts(:with_platform)
    existing = podcast.episodes.create!(provider_id: "3586072", title: "Edited title", url: "https://example.com/e")
    Transistor.stubs(:published_episodes).returns([transistor_episode])

    assert_no_difference -> { Episode.count } do
      podcast.import_transistor_episodes
    end

    assert_equal "Edited title", existing.reload.title
  end

  test "import_transistor_episodes reports invalid episodes and imports the rest" do
    podcast = podcasts(:with_platform)
    invalid = transistor_episode(id: "1", share_url: nil)
    valid = transistor_episode(id: "2")
    Transistor.stubs(:published_episodes).returns([invalid, valid])

    Bugsnag.expects(:notify).once

    podcast.import_transistor_episodes

    assert_nil podcast.episodes.find_by(provider_id: "1")
    assert podcast.episodes.exists?(provider_id: "2")
  end

  private

  def transistor_episode(id: "3586072", share_url: "https://share.transistor.fm/s/5b2b5c43")
    Transistor::Episode.new(
      id: id,
      title: "TIFF 2026 Round Table #3",
      summary: "<p>Summary</p>",
      description: "<p>Description</p>",
      share_url: share_url,
      embed_html: "<iframe></iframe>",
      slug: "tiff-2026-round-table-3",
      published_at: "2026-09-21T02:29:36.000Z",
      duration: 4400,
    )
  end
end
