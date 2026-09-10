# frozen_string_literal: true

module Share
  module Publisher
    class Instagram < Base
      # Meta retires Graph API versions on a roughly two-year cadence — check
      # https://developers.facebook.com/docs/graph-api/changelog for the current
      # version before this one is deprecated.
      GRAPH_API_VERSION = "v21.0"
      GRAPH_API_BASE = "https://graph.facebook.com/#{GRAPH_API_VERSION}"
      MIN_CAROUSEL_ITEMS = 2
      MAX_CAROUSEL_ITEMS = 10

      def initialize(
        access_token: Rails.application.credentials.dig(:instagram, :access_token),
        ig_user_id: Rails.application.credentials.dig(:instagram, :business_account_id)
      )
        super()
        @access_token = access_token
        @ig_user_id = ig_user_id
      end

      def publish!(image_urls:, caption:)
        validate_image_count!(image_urls)

        child_ids = image_urls.map { |url| create_carousel_item(url) }
        creation_id = create_carousel_container(child_ids, caption)
        publish_container(creation_id)
      end

      private

      def validate_image_count!(image_urls)
        return if image_urls.size.between?(MIN_CAROUSEL_ITEMS, MAX_CAROUSEL_ITEMS)

        raise ArgumentError,
          "Instagram carousels need #{MIN_CAROUSEL_ITEMS}-#{MAX_CAROUSEL_ITEMS} images, got #{image_urls.size}"
      end

      def create_carousel_item(image_url)
        post("/#{@ig_user_id}/media", image_url: image_url, is_carousel_item: true).fetch("id")
      end

      def create_carousel_container(child_ids, caption)
        post("/#{@ig_user_id}/media", media_type: "CAROUSEL", children: child_ids.join(","), caption: caption).fetch("id")
      end

      def publish_container(creation_id)
        post("/#{@ig_user_id}/media_publish", creation_id: creation_id).fetch("id")
      end

      def post(path, params)
        uri = URI("#{GRAPH_API_BASE}#{path}")
        response = Net::HTTP.post_form(uri, params.merge(access_token: @access_token))

        unless response.is_a?(Net::HTTPSuccess)
          raise "Instagram Graph API error (#{response.code}): #{response.body}"
        end

        JSON.parse(response.body)
      end
    end
  end
end
