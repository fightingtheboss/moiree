# frozen_string_literal: true

require "test_helper"

class PublishCarouselJobTest < ActiveJob::TestCase
  # editions(:base) already has fixture selections with >= 4 ratings each;
  # with_no_films starts with zero selections/categories, so the carousel
  # this job renders only ever contains what each test creates.
  setup do
    @edition = editions(:with_no_films)
    @category = Category.create!(edition: @edition, name: "Category")
  end

  test "publishes the carousel and marks the post as posted" do
    rated_selection(title: "Great Film", scores: [5.0, 5.0, 5.0, 5.0])
    social_post = SocialPost.create!(
      edition: @edition,
      content_type: "edition_top_films",
      platform: "instagram",
      caption: "custom caption",
    )
    Share::Publisher::Instagram.any_instance.stubs(:publish!).returns("external-123")

    PublishCarouselJob.perform_now(social_post.id)
    social_post.reload

    assert_equal "posted", social_post.status
    assert_equal "external-123", social_post.external_id
    assert_not_nil social_post.posted_at
    assert_equal 1, social_post.images.count
  end

  test "passes the social post's own caption to the publisher, not a recomputed one" do
    rated_selection(title: "Great Film", scores: [5.0, 5.0, 5.0, 5.0])
    social_post = SocialPost.create!(
      edition: @edition,
      content_type: "edition_top_films",
      platform: "instagram",
      caption: "custom caption",
    )
    Share::Publisher::Instagram.any_instance.expects(:publish!)
      .with(image_urls: anything, caption: "custom caption")
      .returns("external-123")

    PublishCarouselJob.perform_now(social_post.id)
  end

  test "marks the post as failed and re-raises when publishing errors" do
    rated_selection(title: "Great Film", scores: [5.0, 5.0, 5.0, 5.0])
    social_post = SocialPost.create!(edition: @edition, content_type: "edition_top_films", platform: "instagram", caption: "x")
    Share::Publisher::Instagram.any_instance.stubs(:publish!).raises("Graph API is down")

    assert_raises(RuntimeError) { PublishCarouselJob.perform_now(social_post.id) }
    social_post.reload

    assert_equal "failed", social_post.status
    assert_equal "Graph API is down", social_post.error
  end

  test "attaches images as JPEGs (Instagram's Graph API rejects PNG for carousel items)" do
    rated_selection(title: "Great Film", scores: [5.0, 5.0, 5.0, 5.0])
    social_post = SocialPost.create!(edition: @edition, content_type: "edition_top_films", platform: "instagram", caption: "x")
    Share::Publisher::Instagram.any_instance.stubs(:publish!).returns("external-123")

    PublishCarouselJob.perform_now(social_post.id)
    social_post.reload
    attachment = social_post.images.first

    assert_equal "image/jpeg", attachment.content_type
    assert_equal "1.jpg", attachment.filename.to_s
  end

  test "is a no-op when the social post is already posted, and does not re-publish" do
    rated_selection(title: "Great Film", scores: [5.0, 5.0, 5.0, 5.0])
    social_post = SocialPost.create!(
      edition: @edition,
      content_type: "edition_top_films",
      platform: "instagram",
      caption: "x",
      status: "posted",
      external_id: "already-posted-123",
      posted_at: Time.current,
    )
    Share::Publisher::Instagram.any_instance.expects(:publish!).never

    PublishCarouselJob.perform_now(social_post.id)
    social_post.reload

    assert_equal "posted", social_post.status
    assert_equal "already-posted-123", social_post.external_id
    assert_equal 0, social_post.images.count
  end

  private

  def rated_selection(title:, scores:)
    film = Film.create!(title: title, director: "Test Director", country: "US", year: 2026)
    selection = Selection.create!(edition: @edition, film: film, category: @category)
    raters = [critics(:base), critics(:without_publication), critics(:without_ratings), critics(:frequent_rater), critics(:contrarian)]
    scores.each_with_index do |score, i|
      Rating.create!(critic: raters[i], selection: selection, score: score, skip_cache_average_ratings_callback: true)
    end
    selection
  end
end
