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
  end
end
