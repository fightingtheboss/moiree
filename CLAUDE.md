# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This App Is

Moirée (`moir.ee`) is a film festival rating aggregation platform. Critics rate films at festivals; the app aggregates those ratings into scored selections, edition summaries, and year-in-review pages. It also manages podcast episodes via Transistor.fm and posts daily summary tweets during active festivals.

## Commands

```bash
# Setup
mise install && bundle install && bin/setup --skip-server

# Dev server + Tailwind watcher
bin/dev

# Tests
bin/rails test                              # Full suite (parallel)
bin/rails test test/models/film_test.rb     # Single file
bin/rails test test/models/film_test.rb:42  # Single test by line number
bin/rails test:models
bin/rails test:controllers
bin/rails test:system                       # Capybara + Selenium

# Linting
bin/rubocop        # Check
bin/rubocop -a     # Auto-fix safe violations

# Database
bin/rails db:migrate
bin/rails db:seed
```

## Git Worktrees

Worktrees live in `.claude/worktrees/` (already gitignored).

After creating a worktree, symlink `config/master.key` into it — Rails credentials won't decrypt without it, and tests that make real API calls (e.g. TMDB) will fail with nil responses:

```bash
ln -s /Users/mcfly/Web/rails/moire/config/master.key \
      /Users/mcfly/Web/rails/moire/.claude/worktrees/<branch>/config/master.key
```

## Architecture

### Domain Model

The core hierarchy is: **Festival → Edition → Selection → Rating**

- A `Festival` has many `Edition`s (each festival year/occurrence)
- An `Edition` has many `Selection`s (films programmed into it) and `Attendance`s (critics attending)
- A `Selection` belongs to both an `Edition` and a `Film`, and has many `Rating`s
- A `Rating` belongs to a `Selection` and a `Critic`
- Films are sourced from TMDB (`app/models/tmdb.rb`) — `Film` records store a `tmdb_id`

### User Roles

`User` uses `delegated_type :userable` — the two types are `Admin` and `Critic`. Pundit policies in `app/policies/` control authorization for every resource.

### Authentication

Invitation-based, built on [authentication-zero](https://github.com/lazaronixon/authentication-zero):
- **Critics**: invited → account created → passwordless magic link login (permanent session)
- **Admins**: invited → account created → password reset link → password-based login
- `Current` (via `ActiveSupport::CurrentAttributes`) carries the current user/session through each request

### Admin vs Public

- **Public** routes (`/`, `/editions`, `/films`, `/critics`, `/ratings`, `/podcasts`, `/:year`): read-only, no auth required
- **Admin** routes (`/admin/...`): full CRUD, requires admin auth. All admin controllers live in `app/controllers/admin/` and inherit from `Admin::AdminController`. Use nested class syntax:

```ruby
class Admin
  class FilmsController < AdminController
  end
end
```

### Scoring

Ratings use a Bayesian average. `Selection` has cached average and Bayesian scores that are recalculated via callbacks when ratings change. `Edition` and `YearInReview` aggregate these into summaries.

### Background Jobs

Solid Queue runs inside Puma (`SOLID_QUEUE_IN_PUMA=true` in production). `DailySummaryTweetJob` posts at 11:50pm during active festivals. Mission Control UI is at `/admin/jobs`.

### Share Images

Edition summary/stat share images are generated on-request as PNGs via a dedicated `SharesController` using headless rendering. The routes live under `editions/:id/share/`.

### Frontend

Turbo + Stimulus + Tailwind v4. No Node.js, no npm, no PostCSS — Tailwind compiles via the `tailwindcss-rails` gem's standalone CLI. JavaScript lives in `app/javascript/` with importmap.

### Infrastructure

- **Hosting**: Hetzner CX33 via Kamal, Docker images on Docker Hub
- **SQLite** in production with Litestream replicating all DBs (main, queue, cache, cable) to S3
- **Active Storage**: files on S3
- **SSL**: Cloudflare Origin Certificate (Full Strict mode) — not Let's Encrypt
- **CI/CD**: GitHub Actions — tests on all branches except `main`, deploy to production on push to `main`

## Code Conventions

### Class Methods

Always use `class << self`, not `def self.method`:

```ruby
class << self
  def for(year) = where(year: year)
end
```

### Value Objects

Use `Data.define` for immutable value objects (e.g., `TMDB::Movie`):

```ruby
Result = Data.define(:film_id, :bayesian_score, :average_rating, :ratings_count)
```

### POROs and Concerns

- **Model-specific logic**: namespaced under the model directory — `app/models/film/searchable.rb` defines `Film::Searchable`
- **Shared concerns**: `app/models/concerns/` (e.g., `Summarizable`)
- **No application code in `lib/`** — everything lives in `app/`
- All concerns use `extend ActiveSupport::Concern` with `included do` and `class_methods do`

### Rubocop Style (rubocop-shopify)

- Double-quoted strings always
- Trailing commas in all multi-line collections, arguments, and parameters
- `# frozen_string_literal: true` on every `.rb` file
- 120-character line length

## Test Conventions

- Minitest declarative style: `test "description" do ... end`
- **Fixtures only** — no FactoryBot. Reference with `films(:base)`, `critics(:without_ratings)`, etc.
- **Mocha** for mocking/stubbing
- Admin controller tests always call `sign_in_as(users(:admin))` in `setup`

Key test helpers (defined in `test_helper.rb`):
- `sign_in_as(user)` — POST-based sign-in
- `create_rating(critic:, selection:, score:)` — creates a rating without triggering cache callbacks

## Changelog

Always update `CHANGELOG.md` as part of any change. Update `README.md` for architectural, dev, or deploy changes.
