# frozen_string_literal: true

require "test_helper"

class Admin::Podcasts::EpisodesControllerTest < ActionDispatch::IntegrationTest
  test "request to webhook from unauthorized source is rejected" do
    podcast = podcasts(:base)

    post webhook_admin_podcast_episodes_path(podcast_id: podcast.id), params: {}
    assert_response(:forbidden)
  end

  test "request to webhook with missing event name is rejected" do
    podcast = podcasts(:base)

    post webhook_admin_podcast_episodes_path(podcast_id: podcast.id),
      params: {
        data: {
          id: "episode_123",
          attributes: {
            title: "New Episode",
            formatted_summary: "This is a new episode.",
            formatted_description: "Full description of the new episode.",
            share_url: "https://example.com/new-episode",
            embed_html: "<iframe></iframe>",
            slug: "new-episode",
            published_at: Time.current.iso8601,
            duration: 3600,
            status: "published",
          },
        },
      },
      headers: { "user-agent" => "Transistor.fm/1.0" }

    assert_response(:bad_request)
  end

  test "request to webhook with invalid event name is rejected" do
    podcast = podcasts(:base)

    post webhook_admin_podcast_episodes_path(podcast_id: podcast.id),
      params: {
        event_name: "invalid_event",
        data: {
          id: "episode_123",
          attributes: {
            title: "New Episode",
            formatted_summary: "This is a new episode.",
            formatted_description: "Full description of the new episode.",
            share_url: "https://example.com/new-episode",
            embed_html: "<iframe></iframe>",
            slug: "new-episode",
            published_at: Time.current.iso8601,
            duration: 3600,
            status: "published",
          },
        },
      },
      headers: { "user-agent" => "Transistor.fm/1.0" }

    assert_response(:bad_request)
  end

  test "request to webhook with missing data is rejected" do
    podcast = podcasts(:base)
    post webhook_admin_podcast_episodes_path(podcast_id: podcast.id),
      params: {
        event_name: "episode_published",
        data: {
          id: "episode_123",
          attributes: {
            status: "published",
            # Missing formatted_summary, formatted_description, share_url, embed_html, slug, published_at, duration, status
          },
        },
      },
      headers: { "user-agent" => "Transistor.fm/1.0" }

    assert_response(:unprocessable_entity)
  end
  test "request to webhook with draft episode does not create episode" do
    podcast = podcasts(:base)

    assert_no_difference("Podcast::Episode.count") do
      post webhook_admin_podcast_episodes_path(podcast_id: podcast.id),
        params: {
          event_name: "episode_published",
          data: {
            id: "episode_123",
            attributes: {
              title: "Draft Episode",
              formatted_summary: "This is a draft episode.",
              formatted_description: "Full description of the draft episode.",
              share_url: "https://example.com/draft-episode", # This URL won't be used
              embed_html: "<iframe></iframe>",
              slug: "draft-episode",
              published_at: Time.current.iso8601,
              duration: 3600,
              status: "draft", # Status is draft
            },
          },
        },
        headers: { "user-agent" => "Transistor.fm/1.0" }

      assert_response(:ok)
    end
  end

  test "valid request to webhook creates episode" do
    podcast = podcasts(:base)

    assert_difference("Podcast::Episode.count", 1) do
      post webhook_admin_podcast_episodes_path(podcast_id: podcast.id),
        params: {
          event_name: "episode_published",
          data: {
            id: "episode_123",
            attributes: {
              title: "New Episode",
              formatted_summary: "This is a new episode.",
              formatted_description: "Full description of the new episode.",
              share_url: "https://example.com/new-episode",
              embed_html: "<iframe></iframe>",
              slug: "new-episode",
              published_at: Time.current.iso8601,
              duration: 3600,
              status: "published",
            },
          },
        },
        headers: { "user-agent" => "Transistor.fm/1.0" }

      assert_response(:ok)

      episode = Podcast::Episode.last
      assert_equal("episode_123", episode.provider_id)
      assert_equal("New Episode", episode.title)
      assert_equal("This is a new episode.", episode.summary)
      assert_equal("https://example.com/new-episode", episode.url)
      assert_equal(3600, episode.duration)
      assert_not_nil(episode.published_at)
    end
  end
end
