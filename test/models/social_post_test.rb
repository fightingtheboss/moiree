# frozen_string_literal: true

require "test_helper"

class SocialPostTest < ActiveSupport::TestCase
  test "defaults to pending status" do
    social_post = SocialPost.create!(edition: editions(:base), content_type: "edition_top_films", platform: "instagram")

    assert_equal "pending", social_post.status
  end

  test "is invalid with a status outside the allowed list" do
    social_post = SocialPost.new(
      edition: editions(:base),
      content_type: "edition_top_films",
      platform: "instagram",
      status: "bogus",
    )

    assert_not social_post.valid?
  end

  test "belongs to an edition" do
    social_post = SocialPost.create!(edition: editions(:base), content_type: "edition_top_films", platform: "instagram")

    assert_equal editions(:base), social_post.edition
  end

  test "is invalid with a content_type not registered in PublishCarouselJob::CONTENT_TYPES" do
    social_post = SocialPost.new(edition: editions(:base), content_type: "bogus", platform: "instagram")

    assert_not social_post.valid?
  end

  test "is invalid with a platform not registered in PublishCarouselJob::PUBLISHERS" do
    social_post = SocialPost.new(edition: editions(:base), content_type: "edition_top_films", platform: "bogus")

    assert_not social_post.valid?
  end
end
