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
  - v8
- Turbo
- Tailwind
  - v4

## Database backup
- The app is currently deployed to Fly.io
- We use SQLite in production
- The SQLite database is backed up every day at midnight via a Solid Queue job (BackupDbToS3Job)
- Credentials are coordinated between Fly and AWS via OIDC IdP: [Configure fly.io as a OIDC IdP](https://fly.io/blog/oidc-cloud-roles/)

## Roadmap
- Page caching for the summary!
- Stats
  - One for top 3 in Competition
  - One for top 5 across the rest
  - Ratings per film filtered by country, critic's country
    - This could show the distribution graph, like on Letterboxd
  - Highest rated category
  - Critic's most liked countries
  - Number of 5 star ratings
  - Number of 0 star ratings
  - Number of critics
  - Number of ratings
  - Critic with most ratings (easily tie, so need to handle that)
  - Critic who had a blast (most 5 star ratings / highest average rating)
  - Critic who was least impressed (lowest average rating)
- Replace star rating range input with something more universal
- Grid sorting and filtering
  - Need to show film country
  - Add a filtering toolbar
    - Allows to filter down by category and country (means we need to show country somewhere)
    - Has a search for film by title to redraw the table

### Nice-to-haves
- Add TMDb integration to get Film data and images
  - Make this super simple
    - Provide a field for the TMDB link to the film with a link out to TMDB to help admin find it
      - Could also be the IMDB url, since TMDB has those
    - Use that link on save to fetch the data from the API and cache it
      - This can include extended metadata and URLs to images (posters and banners)
  - Maybe this is an option for Admins to do a search or an automated matching of the entered film data
    - I think it should be automatable if we have the title, directors and year as criteria

### Kamal Deployments (worth exploring)
- Install the litestream-ruby gem and configure it to stream the backups to S3
  - This should replace my ad-hoc job
- Install kamal
- Setup a small server on Hetzner and do a deploy
  - Deploy from a kamal branch rather than main since this will require changes to Dockerfile
- If all works as expected, perhaps move everything over to the new server?
