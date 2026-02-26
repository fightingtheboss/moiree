# frozen_string_literal: true

class Film < ApplicationRecord
  include Importable, Searchable
  include FriendlyId

  has_many :selections, dependent: :destroy, inverse_of: :film
  has_many :editions, through: :selections
  has_many :ratings, through: :selections do
    def for(edition)
      where(selections: { edition_id: edition.id })
    end

    def by(critic)
      where(ratings: { critic: critic })
    end
  end

  normalizes :title, with: lambda(&:strip)
  normalizes :director, with: lambda(&:strip)
  normalizes :country, with: Normalizers::Country.new

  validates :title, :director, :country, :year, presence: true
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1888 }, allow_blank: true
  validate :country_codes_must_be_valid

  before_save :normalize_title, if: :title_changed?

  friendly_id :slug_candidates, use: :slugged

  class << self
    def from_tmdb(tmdb_id)
      tmdb_movie = TMDB.find(tmdb_id)

      new(
        title: tmdb_movie.title,
        original_title: tmdb_movie.original_title,
        director: tmdb_movie.directors.join(", "),
        country: tmdb_movie.countries.join(","),
        year: tmdb_movie.release_date.to_date&.year,
        summary: tmdb_movie.overview,
        release_date: tmdb_movie.release_date,
        poster_path: tmdb_movie.poster_path,
        backdrop_path: tmdb_movie.backdrop_path,
        tmdb_id: tmdb_movie.id,
      )
    end
  end

  def cache_overall_average_rating
    update(overall_average_rating: ratings.average(:score).to_f)
  end

  def directors
    director.split(",").map(&:strip)
  end

  def countries
    country.split(",").map(&:strip).map do |c|
      country_obj = Country[c] || Country.find_country_by_any_name(c)
      country_obj&.common_name || c
    end
  end

  private

  def slug_candidates
    [
      :title,
      [:title, :year],
      [:title, :year, :country],
    ]
  end

  def country_codes_must_be_valid
    invalid = country.split(",").map(&:strip).reject do |c|
      Country[c] || Country.find_country_by_any_name(c)
    end

    errors.add(:country, "contains unknown country name(s) or codes: #{invalid.join(", ")}") if invalid.any?
  end

  def normalize_title
    self.normalized_title = I18n.transliterate(title)
  end
end
