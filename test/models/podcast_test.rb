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
end
