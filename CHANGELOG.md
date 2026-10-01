# Changelog

## 2026-10-01
- Replace Sprockets with Propshaft, fixing deploys that sometimes kept serving the previous release's CSS
  - Kamal's asset bridging copies the previous release's assets, including its randomly named Sprockets manifest, next to the new ones, and Sprockets loaded whichever manifest sorted first. Propshaft always reads `public/assets/.manifest.json`, which the copy never overwrites
  - Remove `app/assets/config/manifest.js` and the directive-only `application.css`; the layouts link `actiontext.css` directly

## 2026-09-30
- Show the edition grid's "N here + M from earlier festivals" tooltip when hovering or tapping the whole average cell, and remove the clock icon that appeared on nearly every average
- Let unverified users request a password reset or sign-in link
  - Both forms previously ignored unverified accounts, so a user who changed their email without verifying it could be locked out entirely
  - Completing a password reset or signing in with a magic link now marks the user verified, since following the emailed link proves they own the address
  - Both forms now respond "If an account exists for that email…" whether or not the account exists. Previously an unknown email got "You can't … until you verify your email", which was misleading and revealed which emails have accounts
  - Fix the passwordless sign-in system test, which never saw the email because the mailer job was not performed, and rename its class from `SessionsTest`, which it shared with `sessions_test.rb`
- Only inherit a critic's rating from editions that ended before the edition being rated ends, so overlapping festivals (e.g. Venice into TIFF) still inherit
  - `Rating.inherit_for` previously took the critic's most recent native rating regardless of date, so a later festival's rating could be inherited into an earlier edition
- Recompute edition averages when inherited ratings or attendances change
  - Averages include inherited ratings, but inheriting ratings for a new attendance or selection, and removing an attendance, did not recompute them
  - Add `Edition#cache_average_ratings` and `CacheEditionAverageRatingsJob`, enqueued when an attendance is removed
- Remove the daily summary tweet
  - X API posting now requires a paid plan, so `DailySummaryTweetJob` could no longer post
  - Remove `DailySummaryTweet`, `DailySummaryTweetJob`, its recurring schedule, and the `x` gem
- Import podcast episodes from Transistor.fm on a schedule instead of via webhook
  - Cloudflare Bot Fight Mode served Transistor webhook requests a managed challenge, so TIFF 2026 episodes were never created; the free plan cannot exempt a path from Bot Fight Mode
  - Add `SyncPodcastEpisodesJob`, scheduled every 4 hours, which creates any published Transistor episodes not yet imported. Previously imported episodes are left untouched so admin edits are preserved
  - Add a `Transistor` API client; only episodes with status `published` are fetched, so scheduled episodes no longer appear before their release
  - `transistor:import_episodes` now uses the same import code
  - Remove the Transistor webhook endpoint (`POST /admin/podcasts/:podcast_id/episodes/webhook`)
- Respond with 404 instead of a 500 (`undefined method 'title' for nil`) when a public podcast episode is not found
- Count inherited ratings in edition averages and summaries, so they reflect what the edition's attending critics think of each film rather than only ratings made at the festival
  - `Selection#cache_average_rating` averages native and inherited ratings from attending critics; remove the `Selection#native_ratings` association
  - Edition summaries (minimum-ratings threshold, Bombe Moirée, most divisive, histograms, five-star/zero-star lists) include inherited ratings
  - Year in review stat counts and five-star/zero-star lists stay native-only, since an inherited rating copies a rating from an earlier edition that may fall in the same year
  - Show a "N here + M from earlier festivals" tooltip on the edition grid average when it includes inherited ratings
  - Label inherited ratings in edition summary five-star/zero-star lists with the edition they were rated at
  - Show the grid's inherited-rating and average tooltips on tap/focus so they work on mobile, and hide them when the grid scrolls
  - Replace their native `title` tooltips, which appeared alongside the custom tooltip, with `aria-label`s
  - Wrap the average tooltip and anchor it to the right so it stays on screen on mobile
- Keep category titles in view when scrolling the edition grid horizontally
- Fix the edition grid page showing two vertical scrollbars on desktop
  - The grid's height calc predated the Patreon banner, so the page overflowed by the banner's height; use `dvh` so mobile browser toolbars don't cause the same overflow
- Fix film overall average double-counting critics whose rating was inherited into a later edition
  - `Film#cache_overall_average_rating` now counts each critic once, using their most recent native rating (by edition end date), and skips critics whose most recent rating is a walk-out

## 2026-09-09
- Fix `Vips::Error: svgload_buffer: operation is blocked` breaking edition share images in production
  - `image_processing` 2.x calls `Vips.block_untrusted(true)` on load as an XXE/SSRF mitigation, which blocks SVG loading; `SharesController#overview` renders our own template-generated SVG, so unblock that loader specifically in `config/initializers/vips.rb`
- Switch Dependabot to weekly, grouped updates
  - Bundler and GitHub Actions updates now run weekly instead of daily, with patch/minor bumps grouped into a single PR per ecosystem so they stop piling up one-PR-per-dependency
- Bump `image_processing` from 1.14.0 to 2.1.0 and add `ruby-vips` as an explicit dependency
  - `image_processing` 2.x no longer bundles `mini_magick`/`ruby-vips` transitively; without declaring `ruby-vips` directly the app fails to boot (`config/initializers/vips.rb` requires `vips`)

## 2026-09-08
- Sort the edition ratings grid case-insensitively and ignoring leading articles ("The", "A", "An")
  - Add `Film#sort_title`, computed alongside `normalized_title` whenever the title changes
  - Extend the ignored-article list to French, Spanish, and Italian definite/indefinite articles, including elided forms ("L'Avventura", "Un'Estate Italiana")
  - Fix elided-article stripping for titles using a curly apostrophe ("L’Avventura"), which `I18n.transliterate` was mangling before the article regex could match it
  - Use `films.sort_title` for the other film-title orderings (critic ratings page, year-in-review/edition five-star and zero-star lists, admin edition and film selection lists) so sorting is consistent everywhere

## 2026-09-01
- Fix `NameError` when adding a critic to an edition's attendance list
  - The `create` turbo_stream response was missing the `edition` local passed to the critic partial

## 2026-05-23
- Keep walked-out ratings at the bottom on film pages and critic pages within each edition list
- Make public rating detail modals span the available width on mobile
  - Keep the impression/review-link modal full width on small screens aside from its side margins

## 2026-05-17
- Add walked-out ratings support
  - Add `walked_out` flag on ratings and normalize walked-out scores to `0.0`
  - Exclude walked-out ratings from averages and year-in-review aggregations
  - Add walked-out checkbox/support text in admin rating modal and disable score slider when selected
  - Render walked-out ratings as `🚪🚶` in rating displays

## 2026-05-05
- Remove average rating label from top 5 films on the homepage
- Hide critic impression from the bottom of top 5 film cards on year-in-review pages

## 2026-04-23
- Remove Skylight monitoring
  - Drop the `skylight` gem and remove its application config
- Fix GitHub Actions deploy handling for Cloudflare origin certificate secrets
  - Write PEM values to files before building `.kamal/secrets` so Kamal can load valid multiline certs

## 2026-04-22
- Update GitHub Actions checkout steps to `actions/checkout@v6`
  - Update `webfactory/ssh-agent` to `v0.10.0` and audit workflow actions for Node 20 dependencies
  - Removes reliance on the Node 20 runtime in the CI and deploy workflows
  - Picks up the latest checkout action changes, including improved credential handling

## 2026-04-11
- Migrate deployment from Fly.io to Kamal on Hetzner
  - Replace LiteFS with Litestream for continuous SQLite replication to S3
  - Use Docker Hub as the container registry
  - Deploy via Kamal with Thruster as the HTTP accelerator
  - Update GitHub Actions workflow to deploy with Kamal
  - Manage deploy secrets via 1Password adapter locally, env vars in CI
  - Use a Cloudflare Origin Certificate for proxied SSL, with certs stored under `/etc/ssl/cloudflare`
  - Remove BackupDbToS3Job (replaced by Litestream continuous replication)

## 2026-01-31
- Concept of unrateable film
  - Should be called out to both critics and to end users

## 2025-12-03
- Add a public index of all critics who've rated for MOIRÉE
  - Link to index in top menu bar

## 2025-11-27
- Add TMDb integration to get Film data and images
  - Automatically searches when adding or editing a film
  - Searches TMDB by title and year (those are the only options on TMDB API)
  - Stores high-level film info, including poster and backdrop image paths

## 2025-08-15
- Concept of unrateable film
  - Flag on the film
  - Films flagged are unrateable at any edition

## 2025-08-08
- Podcasts
  - Index of podcasts and episodes
    - Need to add a link to this in the top menu for all users
    - Since this is on the only podcast, should probably skip over the podcast index view for now and go straight to the MOIRÉE podcast episodes
  - Ability to add new podcast episodes
    - Listen for webhooks when new episodes are published on transistor.fm
      - Looks like I'll need a rake task to register for the webhoook initially
    - Grab the details directly, so there's no need for double entry of details
  - Show view with an embed of the player, a link to transistor.fm
  - Associate each episode to an edition, optionally

## 2025-03-23
- Add shareable cards and views for end of fest
  - Only for editions views for the time being
  - Cached when the edition is no longer being updated

## 2025-03-16
- Upgrade to Tailwind v4

## 2025-03-09
- Upgrade to Rails 8
  - Upgrade Solid Queue, Cache and Cable to use separate DBs
  - Improve Authentication based on the Rails generator
  - App now runs in a devcontainer locally

## 2024-05-29
- Add a nav bar to reach the Grid, Live, and Summary views
  - Summary empty state can handle empty state
- Have a view that shows all ratings by most recent
  - When festival is current, it refreshes automatically every 7 minutes

## 2024-05-28
- Add summary view and controller for a festival for when it's done
  - Top 3 in Competition
  - Top 5 across the rest
  - Number of 5 star ratings
  - Number of 0 star ratings
  - Most divisive film (with histogram of rating distribution)

## 2024-05-26
- Remap categorizations to belong_to selections rather than films
  - category has_many selections
  - selection belongs_to category
  - Remove Categorizations model
  - Update all dependent code

## 2024-05-23
- Ensure average caches are updated when a rating is deleted
- Ensure that the tweet is within the 280 character limit
  - Moved the logic out of the job into PORO class DailySummaryTweet
  -

## 2024-05-22
- Install Solid Queue to handle jobs via SQLite
- Add DailySummaryTweetJob to post a tweet every day at midnight with a roundup
- Cache average rating for selections on Rating create and destroy rather than calculating every time
  - This is done via background job now, rather than having the callbacks have direct side-effects
- Add ability for critics to delete their ratings

## 2024-05-13
- Add ability to edit Critics
- Change five star rating to 🔥 instead of 🤩
- Add friendly_id gem and update the app to use throughout

## 2024-05-12
- Fixes for grid rendering on Safari

## 2024-05-11
- Add ability to mark a Critic as attending an Edition
  - Attending critics will show up in the grid even if they haven't rated anything yet (solves the cold start problem)
  - Critics can't rate films in Editions they're not set to attend
  - Admins mark Critics as attending an Edition via the drag-and-drop admin

## 2024-05-05
- Add detail view for Film showing all of the ratings across Editions, as well as overall
- Add detail view for Critic showing all of their ratings, per Edition
- Wire up links to Films and Critics everywhere
- Standardize the layout padding across public and admin pages
- Fix missing logo in transactional emails

## 2024-05-04
- Category ordering
  - A drag-and-drop view for defining the order categories will be displayed in grid
  - Only Admins can see the Category view in the admin menu for an Edition

## 2024-05-01
- Added ability to filter out Critics from the grid and reset the filters
- Added director name to Film column
- Grouped table by Category and added sticky Category headers
- Overall styling improvements to the grid
- https://youtu.be/fkhbR7jaE3o
