# frozen_string_literal: true

namespace :db do
  desc "Populate database with data for all homepage sections"
  task populate_homepage: :environment do
    puts "=" * 60
    puts "HOMEPAGE DATA VERIFICATION"
    puts "=" * 60

    today = Date.current
    this_year = today.year

    puts "\n✅ SECTION 1: Live Now (current festivals)"
    current = Edition.current
    puts "   Count: #{current.count}"
    current.each do |e|
      puts "   - #{e.code}: #{e.critics.count} critics, #{e.films.count} films, #{e.ratings.count} ratings (Day #{e.current_day})"
    end

    puts "\n✅ SECTION 2: Best of #{this_year} (top films with impressions)"
    edition_ids = Edition.where("start_date >= ? AND start_date < ?", Date.new(this_year, 1, 1), Date.new(this_year + 1, 1, 1)).pluck(:id)
    top_films = Selection.joins(:ratings, :film)
      .where(edition_id: edition_ids)
      .where.not(ratings: { impression: [nil, ""] })
      .group("selections.id")
      .having("COUNT(ratings.id) >= 2")
      .order("AVG(ratings.score) DESC")
      .limit(5)
      .includes(:film, ratings: :critic)
    puts "   Count: #{top_films.count}"
    top_films.each do |s|
      impression_count = s.ratings.select { |r| r.impression.present? }.count
      puts "   - #{s.film.title} (#{s.average_rating.round(1)}) - #{impression_count} impressions"
    end

    puts "\n✅ SECTION 3: Most Recent Festival"
    recent = Edition.past.where("start_date >= ? AND start_date < ?", Date.new(this_year, 1, 1), Date.new(this_year + 1, 1, 1)).first
    if recent
      puts "   - #{recent.code}: #{recent.critics.count} critics, #{recent.films.count} films, #{recent.ratings.count} ratings"
    else
      puts "   - None found"
    end

    puts "\n✅ SECTION 4: Latest Podcast Episode"
    episode = Episode.order(published_at: :desc).first
    if episode
      puts "   - Title: #{episode.title}"
      puts "   - Published: #{episode.published_at&.strftime("%B %d, %Y")}"
      puts "   - Podcast: #{episode.podcast.title}"
      puts "   - Edition: #{episode.edition&.code || "N/A"}"
    else
      puts "   - None found"
    end

    puts "\n✅ SECTION 5: Coming Soon (upcoming festivals)"
    upcoming = Edition.upcoming
    puts "   Count: #{upcoming.count}"
    upcoming.each do |e|
      days_until = (e.start_date - today).to_i
      puts "   - #{e.code}: #{e.start_date.strftime("%B %d")} - #{e.end_date.strftime("%B %d, %Y")} (#{days_until} days away)"
    end

    puts "\n✅ SECTION 6: Recent Coverage (past festivals)"
    past = Edition.past.where("start_date >= ? AND start_date < ?", Date.new(this_year, 1, 1), Date.new(this_year + 1, 1, 1)).limit(6)
    puts "   Count: #{past.count}"
    past.each do |e|
      puts "   - #{e.code}: #{e.films.count} films, #{e.ratings.count} ratings"
    end

    puts "\n" + "=" * 60
    puts "All 6 homepage sections should now be visible!"
    puts "Run: bin/dev and visit http://localhost:3000"
    puts "=" * 60
  end
end
