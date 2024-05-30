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
- Make shareable cards and views for end of fest
  - Generate a dynamic SVG and convert to PNG (as suggested by ChatGPT) for sharing URLs
    - This would have an SVG template (and maybe a dedicated controller?)
    - Would need to install either image_processing or the vips gem
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
    - Use that link on save to fetch the data from the API and cache it
      - This can include extended metadata and URLs to images (posters and banners)
  - Maybe this is an option for Admins to do a search or an automated matching of the entered film data
    - I think it should be automatable if we have the title, directors and year as criteria
