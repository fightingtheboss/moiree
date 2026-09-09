# frozen_string_literal: true

class Admin
  class SocialPostsController < AdminController
    layout :editions_layout

    before_action :set_festival_and_edition

    def new
      authorize(SocialPost)

      @content = Share::Content::EditionTopFilms.new(@edition)
      @carousel = Share::Carousel.new(@content, width: 1080, height: 1080)
      @social_post = @edition.social_posts.new(
        content_type: "edition_top_films",
        platform: "instagram",
        caption: @carousel.caption,
      )
      @existing_post_today = @edition.social_posts.posted
        .where(content_type: "edition_top_films", created_at: Time.zone.today.all_day)
        .order(created_at: :desc)
        .first
    end

    def create
      authorize(SocialPost)

      @social_post = @edition.social_posts.create!(
        content_type: social_post_params[:content_type],
        platform: "instagram",
        caption: social_post_params[:caption],
      )
      PublishCarouselJob.perform_later(@social_post.id)

      redirect_to(
        admin_festival_edition_social_post_path(@festival, @edition, @social_post),
        notice: "Posting to Instagram…",
      )
    end

    def show
      @social_post = @edition.social_posts.find(params[:id])
      authorize(@social_post)
    end

    private

    def social_post_params
      params.require(:social_post).permit(:content_type, :caption)
    end

    def set_festival_and_edition
      @edition = Edition.includes(:festival).friendly.find(params[:edition_id])
      @festival = @edition.festival
    end

    def editions_layout
      return "turbo_rails/frame" if turbo_frame_request?

      "admin/editions"
    end
  end
end
