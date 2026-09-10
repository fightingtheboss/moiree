# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

# `webmock/minitest` calls `WebMock.enable!` once, process-wide, at require time — and by
# WebMock's own strict defaults that immediately blocks every unstubbed connection, not just
# ones made by this file's own tests. Rails' `parallelize` requires every test file into a
# single parent process before forking workers, so this happens once, in that shared parent,
# before any test runs — every forked worker inherits the block for its *entire life*, not just
# while this file's tests are running. That broke real-network tests elsewhere in the suite
# (e.g. Admin::FilmsController/SelectionsController tests that genuinely hit api.themoviedb.org).
# Undo the blanket block immediately, then re-enable it narrowly via setup/teardown so only this
# class's own test methods are ever affected — each worker is single-threaded and runs tests
# sequentially, so no other test can be "in progress" during that window.
WebMock.allow_net_connect!

class Share::Publisher::InstagramTest < ActiveSupport::TestCase
  BASE = "https://graph.facebook.com/v21.0"

  setup do
    WebMock.disable_net_connect!(allow_localhost: true)
    @publisher = Share::Publisher::Instagram.new(access_token: "test-token", ig_user_id: "123")
  end

  teardown do
    WebMock.allow_net_connect!
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

  test "#publish! raises with the Graph API's error body on failure" do
    stub_request(:post, "#{BASE}/123/media")
      .to_return(status: 400, body: { error: { message: "Invalid image URL" } }.to_json)

    error = assert_raises(RuntimeError) do
      @publisher.publish!(image_urls: ["https://example.com/1.png", "https://example.com/2.png"], caption: "hello")
    end
    assert_includes error.message, "Invalid image URL"
  end

  test "#publish! raises with the raw response body, not JSON::ParserError, on a non-JSON error response" do
    stub_request(:post, "#{BASE}/123/media")
      .to_return(status: 502, body: "<html><body>Bad Gateway</body></html>")

    error = assert_raises(RuntimeError) do
      @publisher.publish!(image_urls: ["https://example.com/1.png", "https://example.com/2.png"], caption: "hello")
    end
    assert_includes error.message, "502"
    assert_includes error.message, "Bad Gateway"
  end
end
