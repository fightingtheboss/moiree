# Moirée - AI Coding Agent Instructions

## Project Overview
Rails 8.0.2 film festival rating aggregation app. Public site + admin interface for festivals/editions/critics/ratings. Includes podcast management with Transistor.fm integration.

**Stack:** Ruby 3.4.2 (REQUIRED) | Rails 8.0.2 | SQLite3 | Turbo + Tailwind v4 | Solid Queue (background jobs)
**System Deps:** libvips, libvips-dev, pkg-config, build-essential (for image_processing gem)
**Production:** Fly.io with LiteFS (SQLite replication), Solid Queue runs in Puma (`SOLID_QUEUE_IN_PUMA=true`)

## Key Structure
```
app/controllers/admin/  → Admin namespace (all admin features)
app/models/            → Film, Edition, Rating, Critic, User, etc.
app/jobs/              → BackupDbToS3Job, DailySummaryTweetJob
config/routes.rb       → Admin routes under `namespace :admin`
config/puma.rb         → Solid Queue plugin config
config/litefs.yml      → Production SQLite replication
config/recurring.yml   → Scheduled jobs (midnight backup, 11:50pm tweet)
db/schema.rb           → Main schema (+ queue/cache/cable schemas)
test/                  → Minitest (unit/integration/system with Capybara/Selenium)
```

## Setup & Build (CRITICAL - Follow Order)

**Prerequisites:** Ruby 3.4.2, bundler, SQLite3, libvips libs. Use `ruby/setup-ruby@v1` in CI or `.devcontainer/`.

```bash
# 1. Install dependencies
bundle install
# Error: "Ruby version 3.x.x but Gemfile specified 3.4.2"? Install Ruby 3.4.2 or use devcontainer.

# 2. Setup database (creates storage/*.sqlite3 + runs migrations)
bin/rails db:prepare

# 3. Full setup (or use bin/setup to auto-start server)
bin/setup --skip-server  # Runs bundle, db:prepare, log/tmp cleanup
```

## Development

```bash
# Start server + Tailwind watch
bin/dev  # Or separately: bin/rails server (port 3000) + bin/rails tailwindcss:watch

# Database
bin/rails db:migrate       # Run migrations
bin/rails db:seed          # Load seed data
bin/rails db:test:prepare  # Prepare test DB (used in CI)
```

## Testing (ALWAYS Before Committing)

```bash
# Run all tests (~30-60s, parallel by default)
bin/rails test

# Specific types
bin/rails test:models
bin/rails test:controllers
bin/rails test:system  # Capybara + Selenium

# CI test preparation (matches .github/workflows/ci.yml)
bin/rails db:test:prepare && bin/rails test:prepare && bin/rails test
```

**Test Helpers:** `sign_in_as(user)` in test_helper.rb, fixtures in `test/fixtures/*.yml`, Mocha for mocking

## Linting

```bash
bin/rubocop           # Run style checks (.rubocop.yml inherits rubocop-shopify)
bin/rubocop -a        # Auto-fix safe violations
```
**Note:** Lint job commented out in CI but run locally before committing.

## Assets & Compilation

**Development:** Tailwind auto-compiles via `bin/rails tailwindcss:watch` (part of `bin/dev`). NO Node.js/webpack.

**Production/Docker:**
```bash
SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile  # Precompile without real credentials
bundle exec bootsnap precompile --gemfile && bundle exec bootsnap precompile app/ lib/  # Docker only
```

## CI/CD Pipeline

**CI (.github/workflows/ci.yml)** - Runs on all branches except `main`:
1. Install: libvips, libvips-dev, pkg-config, build-essential
2. Ruby 3.4.2 + gems via `ruby/setup-ruby@v1` (auto-caches)
3. `bin/rails db:test:prepare`
4. `bin/rails test:prepare` (build assets for tests)
5. `bin/rails test`

**Deploy (.github/workflows/deploy.yml)** - `main` branch:
1. Run CI workflow
2. `flyctl deploy --remote-only --depot=false`

## Background Jobs

**Solid Queue:** Runs in Puma via `plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]` (see config/puma.rb)
**Mission Control UI:** `/admin/jobs` (admin auth required)
**Recurring Jobs (config/recurring.yml):**
- `BackupDbToS3Job`: Midnight (exports to S3 via LiteFS + AWS OIDC)
- `DailySummaryTweetJob`: 11:50pm

```bash
bin/rails jobs:start  # Start worker manually
bin/rails runner "BackupDbToS3Job.perform_now"  # Run specific job
```

## Common Errors & Fixes

**1. Ruby version mismatch:** Install Ruby 3.4.2 or use `.devcontainer/`
**2. Missing libvips:** `sudo apt-get install -y libvips libvips-dev pkg-config build-essential`
**3. Asset precompile error:** Use `SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile`
**4. SQLite locked:** Stop all Rails servers/tests (SQLite doesn't handle concurrent writes well)

## Project Conventions

**Coding Guidelines:**
- Conform to idiomatic Ruby and Rails as much as possible
- Use concerns to keep models small and focused where needed (if not reusable, namespace to model)
- Follow the wisdom of Sandi Metz

**Admin Features:**
- Controllers: `app/controllers/admin/` (inherit from `Admin::AdminController`)
- Routes: `namespace :admin` in config/routes.rb
- Example: `app/controllers/admin/podcasts_controller.rb`

**Database:**
- Main: `storage/development.sqlite3` (db/schema.rb)
- Queue: `storage/development_queue.sqlite3` (db/queue_schema.rb)
- Cache/Cable: Similar pattern (see config/database.yml)

**Tailwind:** v4 via standalone CLI (`tailwindcss-rails` gem). NO Node.js/npm/PostCSS.

## Critical Files Before Changes
- `config/routes.rb` — Routing
- `config/application.rb` — Mission Control config
- `config/puma.rb` — Solid Queue plugin
- `config/litefs.yml` — Production DB replication (be cautious!)
- `Dockerfile` — Production build
- `.github/workflows/ci.yml` — CI validation
- `Gemfile` — Check versions before adding/upgrading

## Root Files Reference
```
.devcontainer/         → Docker devcontainer with Ruby 3.4.2
.github/workflows/     → ci.yml (test), deploy.yml (Fly.io)
.rubocop.yml          → Style config (inherits rubocop-shopify)
.ruby-version         → 3.4.2
Dockerfile            → Production build (LiteFS entrypoint)
Gemfile               → Ruby 3.4.2, Rails 8.0.2, solid_queue, tailwindcss-rails, pundit, etc.
Procfile.dev          → web: bin/rails server, css: bin/rails tailwindcss:watch
README.md             → App context, auth flow, roadmap, DB backup details
Rakefile              → Standard Rails tasks
bin/dev               → Start Rails server wrapper
bin/setup             → Idempotent setup (bundle, db:prepare, cleanup)
bin/rubocop           → Rubocop with explicit config
config.ru             → Rack config
fly.toml              → Fly.io deployment (SOLID_QUEUE_IN_PUMA=true, AWS_ROLE_ARN)
```

## Trust These Instructions
All commands validated. Only explore if: (1) instructions unclear, (2) undocumented error, (3) need implementation details beyond setup/build/test. For standard tasks, follow exactly as written.
