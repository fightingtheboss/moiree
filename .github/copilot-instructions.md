<!-- .github/copilot-instructions.md
  Purpose: concise, actionable guidance for AI coding agents working on this repo.
  Keep this file short (~20-50 lines) and reference concrete files/commands.
-->

# Quick orientation for AI code contributors

- Project type: Ruby on Rails (Rails 8.0.2) monolith using importmap + Turbo + Tailwind.
- Ruby: 3.4.2 (see `Gemfile`). Core app lives under `app/` with conventional Rails layout.

## Big picture
- Single Rails app that serves both public site and an admin UI (namespaced under `admin`).
- Data store: SQLite (used in production). The Dockerfile and `config/litefs.yml` are used
  to run SQLite with LiteFS on Fly.io for replication/backups. See `Dockerfile` and
  `README.md` (DB backup notes).
- Background jobs and scheduling: uses `solid_queue` / `mission_control-jobs`. Mission Control
  UI is mounted at `/admin/jobs` (see `config/application.rb` and `config/routes.rb`).

## Dev / build / test commands (explicit)
- Start server (development): `bin/rails server` (or `bin/dev` which wraps it).
- Tailwind dev watch: `bin/rails tailwindcss:watch` (Procfile.dev contains `css: bin/rails tailwindcss:watch`).
- Assets precompile (used in Dockerfile):
  `SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile`
- Run tests: `bin/rails test` (system tests present under `test/` — Capybara + Selenium are listed
  in the `:test` group in `Gemfile`).
- Bootsnap precompile (used during image build): `bundle exec bootsnap precompile --gemfile`.

## Project-specific conventions & patterns
- Namespacing: admin controllers live under `app/controllers/admin/...` and admin routes are
  grouped in `namespace :admin` in `config/routes.rb` — follow this pattern for admin features.
- Podcasts: admin podcasts and episodes are namespaced and include a webhook endpoint
  (see `admin/podcasts/episodes_controller` and the `post :webhook` route in `config/routes.rb`).
  There is a planned rake task to register webhooks — check `lib/tasks` for related tasks.
- Jobs: Solid Queue is sometimes run inside Puma (see `config/puma.rb` — `plugin :solid_queue`).
  When adding jobs, ensure they play nicely with `solid_queue`/`mission_control-jobs`.
- Assets: this app uses Rails asset pipeline + Tailwind via `tailwindcss-rails` (no webpack/Node
  build step). Use `bin/rails tailwindcss:build` / `tailwindcss:watch` for CSS workflow.

## Integration points & infra to be aware of
- Fly.io deployment — see `Dockerfile` and `fly.toml` in the repo root.
- LiteFS is configured in Dockerfile (`litefs` entrypoint) and `config/litefs.yml` —
  production SQLite uses LiteFS for atomic replication. Be cautious when changing DB access
  or migrations; follow LiteFS / Fly.io patterns.
- S3 backups: an existing Solid Queue job (`BackupDbToS3Job`) uploads DB backups to S3.
- OIDC with Fly for credentials in production (see README DB backup section).

## Helpful files to inspect when changing behavior
- Routing and controller structure: `config/routes.rb`, `app/controllers/admin/...`.
- Job config and mission control: `config/application.rb`, `config/puma.rb`, `lib/tasks/`.
- Docker & deploy: `Dockerfile`, `fly.toml`.
- Dev commands: `Procfile.dev`, `bin/dev`, and `bin/rails` scripts in `bin/`.
- Tests: `test/` for unit/system tests; `Gemfile` lists test dependencies.

## Do / Don't (practical rules)
- Do: preserve the admin namespace and route structure. New admin endpoints should use
  `app/controllers/admin/...` and update `config/routes.rb` accordingly.
- Do: when touching DB behavior, consider LiteFS implications and how Fly.io runs the app.
- Don't assume a separate background worker stack — `solid_queue` may run inside Puma for
  single-server deployments. Check `SOLID_QUEUE_IN_PUMA` env usage.

If anything here is unclear or you want me to expand an area (jobs, Docker, or podcasts/webhooks),
tell me which part and I'll update this file with concrete examples/snippets.
