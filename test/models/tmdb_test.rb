# frozen_string_literal: true

require "test_helper"

class TMDBTest < ActiveSupport::TestCase
  def setup
    Rails.cache.delete("film/tmdb/configuration")
  end

  test "find returns movie with expected attributes" do
    movie_hash = {
      "id" => 42,
      "title" => "The Answer",
      "overview" => "Life, the universe and everything.",
      "release_date" => "1979-01-01",
      "poster_path" => "/poster.jpg",
      "backdrop_path" => "/backdrop.jpg",
      "original_language" => "en",
      "original_title" => "The Answer",
      "production_countries" => [],
      "origin_country" => [],
      "credits" => { "crew" => [] },
      "images" => {},
    }

    images = Data.define(:base_url, :secure_base_url, :backdrop_sizes, :logo_sizes, :poster_sizes, :profile_sizes, :still_sizes).new(
      base_url: "http://image/",
      secure_base_url: "https://image/",
      backdrop_sizes: ["w300", "original"],
      logo_sizes: [],
      poster_sizes: ["w92", "original"],
      profile_sizes: [],
      still_sizes: [],
    )
    config = TMDB::Configuration.new(images:, change_keys: [])

    TMDB.expects(:request).with("movie/42?append_to_response=credits,images").returns(movie_hash)
    TMDB.stubs(:configuration).returns(config)

    movie = TMDB.find(42)

    assert_instance_of TMDB::Movie, movie
    assert_equal "The Answer", movie.title
    assert_equal "https://image/original/poster.jpg", movie.poster_url
    assert_equal "https://image/original/backdrop.jpg", movie.backdrop_url
  end

  test "search returns movies built from results" do
    search_results = {
      "results" => [
        { "id" => 1, "title" => "First", "overview" => nil, "release_date" => nil, "poster_path" => nil, "backdrop_path" => nil, "original_language" => nil, "original_title" => nil, "production_countries" => [], "origin_country" => [], "credits" => nil, "images" => nil },
        { "id" => 2, "title" => "Second", "overview" => nil, "release_date" => nil, "poster_path" => nil, "backdrop_path" => nil, "original_language" => nil, "original_title" => nil, "production_countries" => [], "origin_country" => [], "credits" => nil, "images" => nil },
      ],
    }

    URI.stubs(:encode).with("star wars").returns("star%20wars")
    TMDB.expects(:request).with("search/movie?query=star%20wars&year=").returns(search_results)

    movies = TMDB.search("star wars")

    assert_equal [1, 2], movies.map(&:id)
    assert movies.all? { |movie| movie.is_a?(TMDB::Movie) }
  end

  test "configuration caches the remote response" do
    raw_config = {
      "images" => {
        "base_url" => "http://image/",
        "secure_base_url" => "https://image/",
        "backdrop_sizes" => ["w300", "original"],
        "logo_sizes" => [],
        "poster_sizes" => ["w92", "original"],
        "profile_sizes" => [],
        "still_sizes" => [],
      },
      "change_keys" => ["a"],
    }

    original_cache = Rails.cache
    memory_store = ActiveSupport::Cache::MemoryStore.new
    Rails.cache = memory_store

    TMDB.expects(:request).with("configuration").once.returns(raw_config)

    first = TMDB.configuration
    second = TMDB.configuration

    assert_equal("https://image/", first.images.secure_base_url)
    assert_equal(first.images.secure_base_url, second.images.secure_base_url)
    assert_equal(first.change_keys, second.change_keys)
  ensure
    Rails.cache = original_cache
  end

  test "poster_url and backdrop_url fall back to original size when missing" do
    images = Data.define(:base_url, :secure_base_url, :backdrop_sizes, :logo_sizes, :poster_sizes, :profile_sizes, :still_sizes).new(
      base_url: "http://image/",
      secure_base_url: "https://image/",
      backdrop_sizes: ["w300"],
      logo_sizes: [],
      poster_sizes: ["w92"],
      profile_sizes: [],
      still_sizes: [],
    )
    config = TMDB::Configuration.new(images:, change_keys: [])

    TMDB.stubs(:configuration).returns(config)

    assert_equal "https://image/original/poster.jpg", TMDB.poster_url("/poster.jpg", size: "invalid")
    assert_equal "https://image/original/backdrop.jpg", TMDB.backdrop_url("/backdrop.jpg", size: "invalid")
  end

  test "movie url helpers return nil when paths absent" do
    movie = TMDB::Movie.new(
      id: 1,
      title: "No Images",
      overview: nil,
      release_date: nil,
      poster_path: nil,
      backdrop_path: nil,
      original_language: nil,
      original_title: nil,
      production_countries: [],
      origin_country: [],
      credits: nil,
      images: nil,
    )

    assert_nil movie.poster_url
    assert_nil movie.backdrop_url
  end

  test "directors returns the names of the directors" do
    credits = { "crew" => [{ "job" => "Director", "name" => "Director 1" }, { "job" => "Writer", "name" => "Writer 1" }] }
    movie = TMDB::Movie.new(
      id: 1,
      title: "Movie",
      overview: nil,
      release_date: nil,
      poster_path: nil,
      backdrop_path: nil,
      original_language: nil,
      original_title: nil,
      production_countries: [],
      origin_country: [],
      credits: credits,
      images: nil,
    )

    assert_equal ["Director 1"], movie.directors
  end

  test "countries returns production_countries when present" do
    movie = TMDB::Movie.new(
      id: 1,
      title: "Movie",
      overview: nil,
      release_date: nil,
      poster_path: nil,
      backdrop_path: nil,
      original_language: nil,
      original_title: nil,
      production_countries: [{ "iso_3166_1" => "US" }],
      origin_country: [],
      credits: nil,
      images: nil,
    )

    assert_equal ["US"], movie.countries
  end

  test "countries returns origin_country when production_countries is empty" do
    movie = TMDB::Movie.new(
      id: 1,
      title: "Movie",
      overview: nil,
      release_date: nil,
      poster_path: nil,
      backdrop_path: nil,
      original_language: nil,
      original_title: nil,
      production_countries: [],
      origin_country: ["GB"],
      credits: nil,
      images: nil,
    )

    assert_equal ["GB"], movie.countries
  end

  test "countries returns empty array when both are empty" do
    movie = TMDB::Movie.new(
      id: 1,
      title: "Movie",
      overview: nil,
      release_date: nil,
      poster_path: nil,
      backdrop_path: nil,
      original_language: nil,
      original_title: nil,
      production_countries: [],
      origin_country: [],
      credits: nil,
      images: nil,
    )

    assert_equal [], movie.countries
  end
end
