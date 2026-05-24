---
name: pre-pr-checklist
description: Verify branch is PR-ready per project standards before pushing
disable-model-invocation: true
---

Run these checks and report pass/fail for each:

1. **Relevant commits only** — `git log main..HEAD --oneline`: confirm all commits belong to this change
2. **Size** — `git diff main --stat`: warn (don't block) if over 300 LOC changed
3. **Linting** — `bundle exec rubocop $(git diff main --name-only | grep '\.rb$' | tr '\n' ' ')`: all changed Ruby files must lint clean
4. **Tests** — `bin/rails test $(git diff main --name-only | grep '_test\.rb$' | tr '\n' ' ')`: related tests must pass
5. **Rebased onto main** — `git merge-base --is-ancestor main HEAD || echo "NEEDS REBASE"`: branch must be current

Report a summary table with ✓/✗ and output for each check. If any check fails, list what needs to be fixed before opening the PR.
