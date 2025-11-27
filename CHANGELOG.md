# Changelog

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
