# frozen_string_literal: true

class Transistor
  class Error < StandardError; end

  Episode = Data.define(
    :id,
    :title,
    :summary,
    :description,
    :share_url,
    :embed_html,
    :slug,
    :published_at,
    :duration,
  )

  BASE_URL = "https://api.transistor.fm/v1"

  class << self
    def published_episodes(show_id)
      response = request("episodes", show_id: show_id, status: "published")

      response["data"].map { |data| episode_from(data) }
    end

    private

    def request(endpoint, params = {})
      uri = URI.parse("#{BASE_URL}/#{endpoint}")
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req["x-api-key"] = Rails.application.credentials.dig(:transistor, :api_key)
      req["Accept"] = "application/json"

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      raise Error, "Transistor request failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def episode_from(data)
      attributes = data["attributes"]

      Episode.new(
        id: data["id"],
        title: attributes["title"],
        summary: attributes["formatted_summary"],
        description: attributes["formatted_description"],
        share_url: attributes["share_url"],
        embed_html: attributes["embed_html"],
        slug: attributes["slug"],
        published_at: attributes["published_at"],
        duration: attributes["duration"],
      )
    end
  end
end
