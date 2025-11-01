# frozen_string_literal: true

class TMDB
  Movie = Data.define(
    :id,
    :title,
    :overview,
    :release_date,
    :poster_path,
    :backdrop_path,
    :original_language,
    :original_title,
  ) do
    def poster_url(size: "original")
      return unless poster_path

      TMDB.poster_url(poster_path, size: size)
    end

    def backdrop_url(size: "original")
      return unless backdrop_path

      TMDB.backdrop_url(backdrop_path, size: size)
    end
  end

  Configuration = Data.define(
    :images,
    :change_keys,
  )

  BASE_URL = "https://api.themoviedb.org/3"

  class << self
    def find(id)
      response = request("movie/#{id}?append_to_response=credits,images")

      tmdb_movie(response)
    end

    def search(query, year: nil)
      response = request("search/movie?query=#{URI.encode_uri_component(query)}&year=#{year}")

      response["results"].map do |result|
        tmdb_movie(result)
      end
    end

    def configuration
      raw = Rails.cache.fetch("film/tmdb/configuration", expires_in: 1.week) do
        request("configuration")
      end

      tmdb_configuration(raw)
    end

    def poster_url(path, size: "original")
      size = "original" unless configuration.images.poster_sizes.include?(size)

      "#{configuration.images.secure_base_url}#{size}#{path}"
    end

    def backdrop_url(path, size: "original")
      size = "original" unless configuration.images.backdrop_sizes.include?(size)

      "#{configuration.images.secure_base_url}#{size}#{path}"
    end

    private

    def request(endpoint)
      uri = URI.parse("#{BASE_URL}/#{endpoint}")
      access_token = Rails.application.credentials.dig(:tmdb, :read_access_token)

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{access_token}"
      req["Accept"] = "application/json"

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(req)
      end

      JSON.parse(response.body)
    end

    def tmdb_movie(tmdb_response)
      Movie.new(
        id: tmdb_response["id"],
        title: tmdb_response["title"],
        overview: tmdb_response["overview"],
        release_date: tmdb_response["release_date"],
        poster_path: tmdb_response["poster_path"],
        backdrop_path: tmdb_response["backdrop_path"],
        original_language: tmdb_response["original_language"],
        original_title: tmdb_response["original_title"],
      )
    end

    def tmdb_configuration(tmdb_response)
      images = tmdb_response["images"]

      Configuration.new(
        images: Data.define(
          :base_url,
          :secure_base_url,
          :backdrop_sizes,
          :logo_sizes,
          :poster_sizes,
          :profile_sizes,
          :still_sizes,
        ).new(
          base_url: images["base_url"],
          secure_base_url: images["secure_base_url"],
          backdrop_sizes: images["backdrop_sizes"],
          logo_sizes: images["logo_sizes"],
          poster_sizes: images["poster_sizes"],
          profile_sizes: images["profile_sizes"],
          still_sizes: images["still_sizes"],
        ),
        change_keys: tmdb_response["change_keys"],
      )
    end
  end
end
