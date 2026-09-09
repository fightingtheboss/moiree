# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

class Share::Publisher::InstagramTest < ActiveSupport::TestCase
  BASE = "https://graph.facebook.com/v21.0"

  setup do
    @publisher = Share::Publisher::Instagram.new(access_token: "test-token", ig_user_id: "123")
  end

  test "#publish! creates a container per image, a carousel container, then publishes" do
    stub_request(:post, "#{BASE}/123/media")
      .with(body: hash_including("image_url" => "https://example.com/1.png", "is_carousel_item" => "true"))
      .to_return(body: { id: "child-1" }.to_json)
    stub_request(:post, "#{BASE}/123/media")
      .with(body: hash_including("image_url" => "https://example.com/2.png", "is_carousel_item" => "true"))
      .to_return(body: { id: "child-2" }.to_json)
    stub_request(:post, "#{BASE}/123/media")
      .with(body: hash_including("media_type" => "CAROUSEL", "children" => "child-1,child-2", "caption" => "hello"))
      .to_return(body: { id: "creation-1" }.to_json)
    stub_request(:post, "#{BASE}/123/media_publish")
      .with(body: hash_including("creation_id" => "creation-1"))
      .to_return(body: { id: "published-1" }.to_json)

    result = @publisher.publish!(image_urls: ["https://example.com/1.png", "https://example.com/2.png"], caption: "hello")

    assert_equal "published-1", result
  end

  test "#publish! raises when given fewer than 2 images" do
    assert_raises(ArgumentError) do
      @publisher.publish!(image_urls: ["https://example.com/1.png"], caption: "hello")
    end
  end

  test "#publish! raises when given more than 10 images" do
    urls = Array.new(11) { |i| "https://example.com/#{i}.png" }

    assert_raises(ArgumentError) do
      @publisher.publish!(image_urls: urls, caption: "hello")
    end
  end

  test "#publish! raises with the Graph API's error message on failure" do
    stub_request(:post, "#{BASE}/123/media")
      .to_return(status: 400, body: { error: { message: "Invalid image URL" } }.to_json)

    error = assert_raises(RuntimeError) do
      @publisher.publish!(image_urls: ["https://example.com/1.png", "https://example.com/2.png"], caption: "hello")
    end
    assert_includes error.message, "Invalid image URL"
  end
end
