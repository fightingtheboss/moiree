# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def sign_in_as(user)
      post(sign_in_url, params: { email: user.email, password: "Secret1*3*5*" })
      user
    end

    def create_rating(critic:, selection:, score:)
      Rating.create!(critic: critic, selection: selection, score: score, skip_cache_average_ratings_callback: true)
    end

    def premiere_selection(edition:, title:, director:, num_ratings: 4, score: 3.0)
      film = Film.create!(title: title, director: director, country: "FR", year: 2026)
      selection = Selection.create!(edition: edition, film: film, category: categories(:base))
      [critics(:base), critics(:without_publication), critics(:without_ratings), critics(:frequent_rater)]
        .first(num_ratings)
        .each do |critic|
          Attendance.find_or_create_by!(critic: critic, edition: edition)
          Rating.create!(selection: selection, critic: critic, score: score, created_at: 1.hour.ago)
        end
      selection.cache_average_rating
      selection
    end
  end
end
