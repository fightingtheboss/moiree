# frozen_string_literal: true

require "test_helper"

class TransistorTest < ActiveSupport::TestCase
  test "published_episodes requests published episodes for the show" do
    Transistor.expects(:request)
      .with("episodes", show_id: "moiree-podcast", status: "published")
      .returns({ "data" => [transistor_episode_hash] })

    episodes = Transistor.published_episodes("moiree-podcast")

    assert_equal 1, episodes.size

    episode = episodes.first

    assert_equal "3586072", episode.id
    assert_equal "TIFF 2026 Round Table #3", episode.title
    assert_equal "<p>Summary</p>", episode.summary
    assert_equal "<p>Description</p>", episode.description
    assert_equal "https://share.transistor.fm/s/5b2b5c43", episode.share_url
    assert_equal "<iframe></iframe>", episode.embed_html
    assert_equal "tiff-2026-round-table-3", episode.slug
    assert_equal "2026-09-21T02:29:36.000Z", episode.published_at
    assert_equal 4400, episode.duration
  end

  test "request raises when the API responds with an error" do
    Net::HTTP.stubs(:start).returns(Net::HTTPInternalServerError.new("1.1", "500", "Internal Server Error"))

    assert_raises(Transistor::Error) do
      Transistor.published_episodes("moiree-podcast")
    end
  end

  private

  def transistor_episode_hash
    {
      "id" => "3586072",
      "type" => "episode",
      "attributes" => {
        "title" => "TIFF 2026 Round Table #3",
        "formatted_summary" => "<p>Summary</p>",
        "formatted_description" => "<p>Description</p>",
        "share_url" => "https://share.transistor.fm/s/5b2b5c43",
        "embed_html" => "<iframe></iframe>",
        "slug" => "tiff-2026-round-table-3",
        "published_at" => "2026-09-21T02:29:36.000Z",
        "duration" => 4400,
        "status" => "published",
      },
    }
  end
end
