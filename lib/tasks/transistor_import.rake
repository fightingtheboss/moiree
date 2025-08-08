# frozen_string_literal: true

require "net/http"
require "json"

namespace :transistor do
  desc "Import episodes from Transistor.fm for the moiree podcast"
  task import_episodes: :environment do
    # Use Transistor.fm API key and Podcast ID from Rails credentials
    api_key = Rails.application.credentials.transistor[:api_key]
    podcast_id = "moiree-podcast"

    if api_key.nil?
      puts "Please set transistor.api_key and transistor.podcast_id in your Rails credentials."
      exit 1
    end

    uri = URI("https://api.transistor.fm/v1/episodes")
    uri.query = URI.encode_www_form(show_id: podcast_id)
    req = Net::HTTP::Get.new(uri)
    req["x-api-key"] = api_key
    req["Accept"] = "application/json"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    unless res.is_a?(Net::HTTPSuccess)
      puts "Failed to fetch episodes: #{res.code} #{res.message}"
      exit 1
    end

    data = JSON.parse(res.body)
    episodes = data["data"] || []

    podcast = Podcast.platform.first
    if podcast.nil?
      puts "No platform podcast found."
      exit 1
    end

    episodes.each do |episode_params|
      attrs = episode_params["attributes"]
      next if attrs["status"] == "draft"

      episode = podcast.episodes.find_or_initialize_by(provider_id: episode_params["id"])
      episode.title = attrs["title"]
      episode.description = attrs["formatted_description"]
      episode.url = attrs["share_url"]
      episode.embed = attrs["embed_html"]
      episode.summary = attrs["formatted_summary"]
      episode.published_at = attrs["published_at"]
      episode.slug = attrs["slug"]
      episode.duration = attrs["duration"]

      if episode.save
        puts "Imported: #{episode.title}"
      else
        puts "Failed to import episode #{attrs["title"]}: #{episode.errors.full_messages.join(", ")}"
      end
    end
  end
end
