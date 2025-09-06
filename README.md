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
- Podcasts
  - Index of podcasts and episodes
    - Need to add a link to this in the top menu for all users
    - Since this is on the only podcast, should probably skip over the podcast index view for now and go straight to the MOIRÉE podcast episodes
  - Ability to add new podcast episodes
    - Listen for webhooks when new episodes are published on transistor.fm
      - Looks like I'll need a rake task to register for the webhoook initially
    - Grab the details directly, so there's no need for double entry of details
  - Sitewide banner to promote new episodes
  - Show view with an embed of the player, a link to transistor.fm
  - Associate each episode to an edition, optionally
- Critics
  - Add a public index of all critics who've rated for MOIRÉE
  - Link to index in top menu bar
  - Could eventually get images associated with critics
- Concept of unrateable film
  - Flag on the film
  - Should be called out to both critics and to end users
- Instagram integration
  - Keep using the SVG approach for the time being
    - Maybe just use it for the layout and then overlay/composite the text to be able to ensure custom fonts?
  - Should be generated in a job that runs nighly during an active festival
  - Need to use ActiveStorage to store the JPG files on S3 so they can be accessed by Instagram
- Move generation of OG images to a scheduled job rather than it being part of the request
  - No need for it to be exactly up to date, could even run it hourly during the festival
- Homepage
  - Continue to start with any ongoing festivals
  - Highlight the most highly reviewed films for the year
    - Maybe pull out the impressions and links for those films and show them in a stylized way
  - Highlight most recent festival until the next one
  - Show the latest podcast episode
  - Continue to highlight upcoming festivals
  - Provide links to all previous episodes
  - Add social media links
- Page caching for the summary!
- When a critic is added to an edition, link their previous ratings for the same film to this edition
  - This might be a copy of the existing Rating records or it might be an association
    - Likely both: A new Rating for that Edition, but associated to the original rating
      - Whole records are copied, including a pre-existing association ID, since we always want to point back to the source
        - Only set the association ID if it's not already set
        - The useful association is the edition_id, rather than the original rating_id, because we'll use it
  - Looking this up when rendering the grid will only slow it down further, will need to ensure a simple way to preload these values
  - Show them dimmed/greyed out in the grid with a popover that indicates which festival it was rated at
  - Can be overridden just by adding a rating for that film at that edition
    - Need to clear out the association in the case of overriding the Rating for this Edition
  - Maybe this is a setting on the festival or edition, should ask Blake what he thinks the default should be
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
    - Do the search, show the user the results, then do the detail lookup once one of those options is selected
      - Either search on blur or on a debounced keyup of title field

### Kamal Deployments (worth exploring)
- Install the litestream-ruby gem and configure it to stream the backups to S3
  - This should replace my ad-hoc job
- Install kamal
- Setup a small server on Hetzner and do a deploy
  - Deploy from a kamal branch rather than main since this will require changes to Dockerfile
- If all works as expected, perhaps move everything over to the new server?
