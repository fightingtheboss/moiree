# AGENTS.md

## Build & Run

```bash
bin/setup --skip-server   # Install deps, prepare DB, clean logs/tmp
bin/dev                   # Start Rails server + Tailwind watcher
bin/rails db:migrate      # Run pending migrations
```

## Testing

Minitest with fixtures. No RSpec, no FactoryBot.

```bash
bin/rails test                              # Full suite (parallel)
bin/rails test test/models/film_test.rb     # Single file
bin/rails test test/models/film_test.rb:42  # Single test by line number
bin/rails test:models                       # All model tests
bin/rails test:controllers                  # All controller tests
bin/rails test:system                       # System tests (Capybara/Selenium)
```

Always run the full suite before committing. Tests run in parallel by default.

## Linting

```bash
bin/rubocop              # Check style (rubocop-shopify base)
bin/rubocop -a           # Auto-fix safe violations
```

Style is enforced by `rubocop-shopify`. Key rules:
- Double-quoted strings always (`"foo"`, never `'foo'`)
- Trailing commas in all multi-line collections, arguments, and parameters
- 120-character line length
- 2-space indentation
- `# frozen_string_literal: true` on every `.rb` file
- No parentheses on zero-argument method definitions
- Parentheses on method calls with arguments

## Production

```bash
fly ssh console --pty -C "/rails/bin/rails console"   # SSH into Rails console
```

## Code Style

### Naming

- Classes: `PascalCase` (`YearInReview`, `DailySummaryTweet`)
- Methods/variables: `snake_case` (`cache_average_rating`, `edition_ids`)
- Predicates: end with `?` (`stale?`, `attending?`, `admin?`)
- Constants: `SCREAMING_SNAKE_CASE` (`MIN_RATINGS_FLOOR`, `BASE_URL`)
- Fixtures: descriptive snake_case (`:base`, `:with_accented_title`, `:without_ratings`)

### Class Methods

Use `class << self` blocks, not `def self.method_name`:

```ruby
class << self
  def for(year)
    # ...
  end
end
```

### Concerns

- **Shared** (multi-model): `app/models/concerns/` (e.g., `Summarizable`, `Userable`)
- **Model-specific**: namespaced under model directory (e.g., `app/models/film/searchable.rb` for `Film::Searchable`)

All concerns use `extend ActiveSupport::Concern` with `included do ... end` for
ActiveRecord macros and `class_methods do ... end` for class-level methods.

### Value Objects

Use `Data.define` for immutable value objects:

```ruby
Result = Data.define(:film_id, :bayesian_score, :average_rating, :ratings_count)
```

### POROs

Place domain logic in plain Ruby objects under model namespace directories:
`app/models/year_in_review/top_films.rb`, `app/models/film/normalizers/country.rb`.

### Error Handling

- Controllers: `rescue ActiveRecord::RecordInvalid` for form submissions
- Concerns: `raise NotImplementedError` for interface contracts
- Models: custom validation methods adding to `errors`
- No global `rescue_from` in `ApplicationController`

### Admin Controllers

Nested class style (not compact), inheriting from `AdminController`:

```ruby
class Admin
  class FilmsController < AdminController
    # ...
  end
end
```

## Test Conventions

### Framework & Data

- **Minitest** declarative style: `test "description" do ... end`
- **Fixtures** exclusively (`test/fixtures/*.yml`), loaded via `fixtures :all`
- **Mocha** for mocking/stubbing

### Assertions

```ruby
assert(expression)
assert_not(expression)
assert_equal(expected, actual)
assert_includes(collection, item)
assert_in_delta(expected, actual, delta)
assert_operator(left, :>, right)
assert_nil(value) / assert_not_nil(value)
assert_difference("Model.count", 1) { ... }
assert_response(:success)
```

### Test Helpers (test_helper.rb)

```ruby
sign_in_as(user)                                    # POST-based sign-in
create_rating(critic:, selection:, score:)           # Rating without cache callback
```

### Test Setup

- Use `setup do ... end` blocks for shared state
- Reference fixtures inline: `films(:base)`, `critics(:without_ratings)`
- Admin controller tests always `sign_in_as(users(:admin))` in setup

## Architecture

| Pattern | Implementation |
|---|---|
| Auth | Pundit policies (`app/policies/`) |
| Background jobs | Solid Queue, `ApplicationJob` base class |
| User roles | `delegated_type :userable` on `User` |
| URL slugs | FriendlyId on public-facing models |
| Request state | `Current` via `ActiveSupport::CurrentAttributes` |
| Frontend | Turbo + Tailwind v4, no Node.js/npm |
| Database | SQLite3 (LiteFS replication in production) |
| Deployment | Fly.io |

## Project Conventions

- Conform to idiomatic Ruby and Rails
- Keep models small; extract concerns and POROs
- Follow the wisdom of Sandi Metz
  - Small objects
  - Duplication is better than the wrong abstraction
  - Inheritance is not evil
    - Aim for a shallow, narrow hierarchy
    - Subclasses should be at the leaf nodes of the object graph
    - Subclasses should use all of the code in the superclass
- Prefer editing existing files over creating new ones
- No application code in `lib/` -- everything lives in `app/`
- Tailwind v4 via standalone CLI gem, no PostCSS/Node.js
- ALWAYS update the CHANGELOG.md as part of any changes
- Update the documentation in README.md when making architectural, dev or deploy related changes
