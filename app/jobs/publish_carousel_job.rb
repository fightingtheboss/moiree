# frozen_string_literal: true

class PublishCarouselJob < ApplicationJob
  CONTENT_TYPES = { "edition_top_films" => Share::Content::EditionTopFilms }.freeze
  PUBLISHERS = { "instagram" => Share::Publisher::Instagram }.freeze

  queue_as :default

  def perform(social_post_id)
    social_post = SocialPost.find(social_post_id)
    return if social_post.status == "posted"

    # Blob#url needs request-derived host/protocol; outside a request (as here, in a job)
    # ActiveStorage::Current.url_options must be set explicitly or it raises ArgumentError.
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
    content = CONTENT_TYPES.fetch(social_post.content_type).new(social_post.edition)
    carousel = Share::Carousel.new(content, width: 1080, height: 1080)

    # A retry after a failure shouldn't accumulate a second set of images alongside the
    # first — purge before re-rendering rather than appending.
    social_post.images.purge if social_post.images.attached?
    carousel.images.each_with_index do |image, index|
      social_post.images.attach(
        io: StringIO.new(image.write_to_buffer(".jpg[Q=90]")),
        filename: "#{index + 1}.jpg",
        content_type: "image/jpeg",
      )
    end

    external_id = PUBLISHERS.fetch(social_post.platform).new.publish!(
      image_urls: social_post.images.map { |attachment| attachment.blob.url },
      caption: social_post.caption,
    )
    social_post.update!(status: "posted", external_id: external_id, posted_at: Time.current)
  rescue => e
    social_post.update!(status: "failed", error: e.message)
    raise
  end
end
