# frozen_string_literal: true

source "https://rubygems.org"

#ruby "3.4.2"

# Use specific branch of Rails
gem "rails", "8.0.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 2.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails", "~> 4.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:windows, :jruby]

gem "csv"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_queue"
gem "solid_cache"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
# gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
# gem "thruster", require: false

gem "mission_control-jobs"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

gem "bugsnag"

gem "countries", "~> 7.0", require: "countries/global"

gem "pundit", "~> 2.3"

gem "positioning"

gem "friendly_id", "~> 5.5.0"

gem "x"

gem "inline_svg"

# Using this for scheduled SQLite DB backups to S3 from Fly.io (with the help of Solid Queue)
gem "aws-sdk-s3", "~> 1"

# Used for replicating SQLite DB to S3 for backups
# gem "litestream"

# Used for tracking performance and errors
gem "newrelic_rpm"
gem "skylight"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  # Lazy loading the debug gem based on the discussion here: https://github.com/ruby/debug/issues/797
  gem "debug", platforms: [:mri, :windows], require: "debug/prelude"

  gem "rubocop", "~> 1", require: false
  gem "rubocop-shopify", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "rails_live_reload"

  gem "faker"

  gem "letter_opener"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "mocha"
end

gem "dockerfile-rails", ">= 1.6", group: :development
