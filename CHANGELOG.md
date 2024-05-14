# Changelog

## 2024-05-13
- Add ability to edit Critics
- Change five star rating to 🔥 instead of 🤩

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
