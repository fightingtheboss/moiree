# Moirée

An app for creating a grid of ratings from critics at film festivals.

## Authentication
Authentication to the app is invitation-based. Admins and Critics are invited by authenticated Admins.
Authentication was originally setup with [authentication-zero](https://github.com/lazaronixon/authentication-zero)

### Critics Invite Flow

When a Critic is invited, their account is created and they're sent a passwordless login link via email. Following that link logs them in permanently (for now).

### Inviting Admins

When an Admin is invited, their account is created and they're sent a link to reset their password. Once they log in, they have all the power and responsibility of a system admin.

## Stack
- Ruby on Rails
- Turbo
- Tailwind


## Roadmap
- Grid sorting and filtering
  - Need to show film country
  - Add a filtering toolbar
    - Allows to filter down by category and country (means we need to show country somewhere)
    - Has a search for film by title to redraw the table
- Critic attendance
  - Adding this association between a Critic and an Edition will signal attendance
  - This will allow us to show the Critic columns in the table before any ratings are entered (could help a bit with the cold start problem)
  - Perhaps this implies that the Admins invite a Critic to review Films at an Edition and otherwise they don't have access (rather than the free-for-all)

### Nice-to-haves
- Could add friendly_id for readable URLs for festival and edition (e.g. /festival/tiff/edition/TIFF24)
- Add TMDb integration to get Film data and images
  - Maybe this is an option for Admins to do a search or an automated matching of the entered film data
    - I think it should be automatable if we have the title, directors and year as criteria
