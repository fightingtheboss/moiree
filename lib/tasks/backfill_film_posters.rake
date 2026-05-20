# frozen_string_literal: true

namespace :films do
  desc "Backfill poster_path (and tmdb_id/backdrop_path) for films missing a poster via TMDB search"
  task backfill_posters: :environment do
    films = Film.where(poster_path: nil).order(:title)

    if films.empty?
      puts "No films missing a poster. Nothing to do."
      next
    end

    puts "#{films.count} film(s) are missing a poster:"
    films.each { |f| puts "  - #{f.title} (#{f.year})" }
    puts
    print "Proceed? This will make up to #{films.count} TMDB API request(s). [y/N] "

    response = $stdin.gets.chomp
    unless response.downcase == "y"
      puts "Aborted."
      next
    end

    updated = 0
    not_found = 0

    films.each do |film|
      results = TMDB.search(film.title, year: film.year)
      match = results.first

      if match&.poster_path.present?
        film.update!(
          tmdb_id: match.id,
          poster_path: match.poster_path,
          backdrop_path: match.backdrop_path,
        )
        puts "  ✓ #{film.title} (#{film.year})"
        updated += 1
      else
        puts "  ✗ #{film.title} (#{film.year}) — no result found"
        not_found += 1
      end

      sleep 0.25
    end

    puts
    puts "Done. #{updated} updated, #{not_found} not found."
  end
end
