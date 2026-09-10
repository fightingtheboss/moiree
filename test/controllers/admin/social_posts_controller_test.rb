# frozen_string_literal: true

require "test_helper"

class Admin::SocialPostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:admin))
  end

  test "new renders a preview without raising" do
    edition = editions(:base)

    get new_admin_festival_edition_social_post_url(edition.festival, edition)

    assert_response :success
  end

  test "new does not render the submit form when fewer than MIN_CAROUSEL_ITEMS films qualify" do
    edition = editions(:with_no_films)
    category = Category.create!(edition: edition, name: "Category")
    film = Film.create!(title: "Solo Film", director: "Test Director", country: "US", year: 2026)
    selection = Selection.create!(edition: edition, film: film, category: category)
    raters = [critics(:base), critics(:without_publication), critics(:without_ratings), critics(:frequent_rater)]
    raters.each do |critic|
      Rating.create!(critic: critic, selection: selection, score: 5.0, skip_cache_average_ratings_callback: true)
    end

    get new_admin_festival_edition_social_post_url(edition.festival, edition)

    assert_response :success
    assert_select "input[type=submit]", false
    assert_match "Not enough films", response.body
  end

  test "create enqueues PublishCarouselJob and redirects to the status page" do
    edition = editions(:base)

    assert_enqueued_with(job: PublishCarouselJob) do
      post admin_festival_edition_social_posts_url(edition.festival, edition),
        params: { social_post: { content_type: "edition_top_films", caption: "Custom caption" } }
    end

    social_post = SocialPost.last
    assert_equal "Custom caption", social_post.caption
    assert_redirected_to admin_festival_edition_social_post_url(edition.festival, edition, social_post)
  end

  test "show renders the post's status" do
    social_post = SocialPost.create!(
      edition: editions(:base),
      content_type: "edition_top_films",
      platform: "instagram",
      caption: "x",
    )

    get admin_festival_edition_social_post_url(editions(:base).festival, editions(:base), social_post)

    assert_response :success
  end

  test "non-admins are not authorized" do
    delete sign_out_url
    sign_in_as(users(:critic))
    edition = editions(:base)

    # This app has no rescue_from Pundit::NotAuthorizedError (see e.g.
    # Admin::PodcastsController, which has the same unguarded `authorize` calls),
    # so an unauthorized request raises rather than redirecting.
    assert_raises(Pundit::NotAuthorizedError) do
      get new_admin_festival_edition_social_post_url(edition.festival, edition)
    end
  end
end
