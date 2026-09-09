# frozen_string_literal: true

class PublishCarouselJob < ApplicationJob
  queue_as :default

  def perform(social_post_id)
    social_post = SocialPost.find(social_post_id)
    # Blob#url needs request-derived host/protocol; outside a request (as here, in a job)
    # ActiveStorage::Current.url_options must be set explicitly or it raises ArgumentError.
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
    content = Share::Content::EditionTopFilms.new(social_post.edition)
    carousel = Share::Carousel.new(content, width: 1080, height: 1080)

    carousel.images.each_with_index do |image, index|
      social_post.images.attach(
        io: StringIO.new(image.write_to_buffer(".png")),
        filename: "#{index + 1}.png",
        content_type: "image/png",
      )
    end

    external_id = Share::Publisher::Instagram.new.publish!(
      image_urls: social_post.images.map { |attachment| attachment.blob.url },
      caption: social_post.caption,
    )
    social_post.update!(status: "posted", external_id: external_id, posted_at: Time.current)
  rescue => e
    social_post.update!(status: "failed", error: e.message)
    raise
  end
end
