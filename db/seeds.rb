# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin_user = User.find_or_create_by!(email: "mina@fightingtheboss.com") do |user|
  user.password = SecureRandom.base58
  user.verified = true
  user.userable = Admin.find_or_create_by!(username: "mina")
end

# Always create a platform podcast — code depends on Podcast.platform.first existing
puts "Creating platform podcast..."

podcast = Podcast.find_or_create_by!(title: "MOIRÉE Podcast") do |p|
  p.user = admin_user
  p.platform = true
  p.description = "The official MOIRÉE podcast covering film festivals around the world."
end
# Ensure platform flag is set even if podcast already existed
podcast.update!(platform: true) unless podcast.platform?

if Rails.env.development?
  puts "\nSeeding development database..."

  today = Date.current
  this_year = today.year

  # ---------------------------------------------------------------------------
  # Podcast Episodes
  # ---------------------------------------------------------------------------
  puts "\nCreating podcast episodes..."

  3.times do |i|
    Episode.find_or_create_by!(podcast: podcast, title: "Episode #{i + 1}: #{Faker::Movie.title}") do |episode|
      episode.url = "https://share.transistor.fm/s/#{SecureRandom.hex(8)}"
      episode.summary = Faker::Lorem.paragraph(sentence_count: 3)
      episode.description = Faker::Lorem.paragraph(sentence_count: 5)
      episode.published_at = (3 - i).weeks.ago
      episode.duration = rand(1800..5400)
    end
  end

  puts "   #{podcast.episodes.count} episodes created."

  # ---------------------------------------------------------------------------
  # Critics
  # ---------------------------------------------------------------------------
  puts "\nCreating 25 critics..."

  (1..25).each do |i|
    User.find_or_create_by!(email: Faker::Internet.email) do |user|
      user.password = SecureRandom.base58
      user.verified = true
      user.userable = Critic.find_or_create_by!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        publication: Faker::Company.name,
        country: ISO3166::Country.codes.sample,
      )
    end
    print "."
  end

  # ---------------------------------------------------------------------------
  # Festivals
  # ---------------------------------------------------------------------------
  puts "\n\nCreating 5 festivals..."

  festival_configs = {
    "Cannes" => { short: "CAN", country: "FR" },
    "Sundance" => { short: "SUN", country: "US" },
    "Venice" => { short: "VEN", country: "IT" },
    "Berlin" => { short: "BER", country: "DE" },
    "Toronto" => { short: "TOR", country: "CA" },
  }

  festivals = festival_configs.map do |name, config|
    festival = Festival.find_or_create_by!(name: name) do |f|
      f.short_name = config[:short]
      f.url = "https://www.#{name.downcase}festival.com"
      f.country = config[:country]
    end
    print "."
    festival
  end

  # ---------------------------------------------------------------------------
  # Editions — deliberately create past, current, and upcoming editions
  # so every homepage section has data.
  # ---------------------------------------------------------------------------
  last_year = this_year - 1
  last_year_suffix = last_year.to_s[-2..]
  this_year_suffix = this_year.to_s[-2..]

  # -- Previous year: one edition per festival (for Year in Review testing) --
  puts "\n\nCreating previous year (#{last_year}) editions..."

  prev_year_edition_configs = [
    { festival: festivals[0], start: Date.new(last_year, 1, 20),  duration: 10 }, # Cannes
    { festival: festivals[1], start: Date.new(last_year, 5, 14),  duration: 12 }, # Sundance
    { festival: festivals[2], start: Date.new(last_year, 8, 27),  duration: 11 }, # Venice
    { festival: festivals[3], start: Date.new(last_year, 2, 12),  duration: 10 }, # Berlin
    { festival: festivals[4], start: Date.new(last_year, 9, 4),   duration: 11 }, # Toronto
  ]

  prev_year_editions = prev_year_edition_configs.map do |config|
    fest = config[:festival]
    edition = fest.editions.find_or_create_by!(year: last_year, code: "#{fest.short_name}#{last_year_suffix}") do |e|
      e.start_date = config[:start]
      e.end_date = config[:start] + config[:duration].days
    end
    puts "   #{edition.code} (#{edition.start_date} → #{edition.end_date})"
    edition
  end

  # -- Current year editions --
  puts "\nCreating current year (#{this_year}) editions (past, current, upcoming)..."

  # Past edition: ended ~3 weeks ago (ensures "Most Recent Festival" + "Recent Coverage")
  past_festival = festivals[0]
  past_start = today - 5.weeks
  past_end = today - 3.weeks

  past_edition = past_festival.editions.find_or_create_by!(year: this_year, code: "#{past_festival.short_name}#{this_year_suffix}") do |edition|
    edition.start_date = past_start
    edition.end_date = past_end
  end
  puts "   Past: #{past_edition.code} (#{past_edition.start_date} → #{past_edition.end_date})"

  # A second past edition for more "Recent Coverage" variety
  past_festival_2 = festivals[1]
  past_start_2 = today - 9.weeks
  past_end_2 = today - 7.weeks

  past_edition_2 = past_festival_2.editions.find_or_create_by!(year: this_year, code: "#{past_festival_2.short_name}#{this_year_suffix}") do |edition|
    edition.start_date = past_start_2
    edition.end_date = past_end_2
  end
  puts "   Past: #{past_edition_2.code} (#{past_edition_2.start_date} → #{past_edition_2.end_date})"

  # Current edition: happening right now (ensures "Live Now")
  current_festival = festivals[2]
  current_start = today - 3.days
  current_end = today + 8.days

  current_edition = current_festival.editions.find_or_create_by!(year: this_year, code: "#{current_festival.short_name}#{this_year_suffix}") do |edition|
    edition.start_date = current_start
    edition.end_date = current_end
  end
  puts "   Current: #{current_edition.code} (#{current_edition.start_date} → #{current_edition.end_date})"

  # Upcoming editions: in the future (ensures "Coming Soon")
  upcoming_configs = [
    { festival: festivals[3], offset: 6.weeks },
    { festival: festivals[4], offset: 14.weeks },
  ]

  upcoming_editions = upcoming_configs.map do |config|
    fest = config[:festival]
    start_date = today + config[:offset]
    edition = fest.editions.find_or_create_by!(year: this_year, code: "#{fest.short_name}#{this_year_suffix}") do |e|
      e.start_date = start_date
      e.end_date = start_date + 11.days
    end
    puts "   Upcoming: #{edition.code} (#{edition.start_date} → #{edition.end_date})"
    edition
  end

  current_year_editions = [past_edition, past_edition_2, current_edition] + upcoming_editions
  all_editions = prev_year_editions + current_year_editions

  # ---------------------------------------------------------------------------
  # Films — ensure most films match current year for YearInReview
  # ---------------------------------------------------------------------------
  puts "\nCreating 150 films (previous + current year)..."

  # Create ~50 films for previous year and ~100 for current year
  150.times do |i|
    film_year = if i < 50
      # First 50 are previous-year films (with ~10% jitter)
      rand(100) < 90 ? last_year : rand(1990..last_year)
    else
      # Remaining 100 are current-year films (with ~10% jitter)
      rand(100) < 90 ? this_year : rand(1990..this_year)
    end

    Film.find_or_create_by!(title: Faker::Movie.unique.title) do |film|
      film.original_title = [film.title, nil].sample
      film.director = Faker::Name.name
      film.country = ISO3166::Country.codes.sample
      film.year = film_year
      film.overall_average_rating = rand(0.0..5.0)
    end
    print "."
  end

  prev_year_films = Film.where(year: last_year).to_a
  current_year_films = Film.where(year: this_year).to_a

  # ---------------------------------------------------------------------------
  # Populate editions with critics, categories, selections, and ratings
  # ---------------------------------------------------------------------------
  puts "\n\nPopulating editions..."

  impressions = [
    "An extraordinary piece of cinema, haunting and beautiful.",
    "Technically impressive but emotionally hollow.",
    "A bold directorial vision that demands a second viewing.",
    "Uneven pacing undermines an otherwise strong cast.",
    "The best film I've seen this year, absolutely riveting.",
    "A quiet masterpiece — delicate, nuanced, and deeply human.",
    "Visually stunning but the narrative feels undercooked.",
    "Provocative and polarizing; this will be debated for years.",
    "Deeply moving, with a performance for the ages.",
    "A disappointment given the talent involved.",
  ]

  all_editions.each do |edition|
    puts "\n-> #{edition.code}"
    print "   Adding critics"

    Critic.all.sample(rand(10..20)).each do |critic|
      edition.attendances.find_or_create_by!(critic: critic)
      print "."
    end

    puts
    print "   Creating categories"

    category_names = Faker::Hipster.words(number: rand(5..10), spaces_allowed: true).uniq
    category_names.each do |category_name|
      edition.categories.find_or_create_by!(name: category_name.capitalize)
      print "."
    end

    puts
    print "   Creating selections"

    # Use matching-year films so YearInReview can find them
    film_pool = if prev_year_editions.include?(edition)
      prev_year_films.any? ? prev_year_films : Film.all.to_a
    else
      current_year_films.any? ? current_year_films : Film.all.to_a
    end
    selection_count = rand(20..50)

    film_pool.sample([selection_count, film_pool.size].min).each do |film|
      edition.selections.find_or_create_by!(film: film) do |selection|
        selection.category = edition.categories.sample
      end
      print "."
    end

    puts
    print "   Creating ratings"

    edition.selections.each do |selection|
      edition.critics.each do |critic|
        next if rand(10) > 7 # ~70% chance of rating

        selection.ratings.find_or_create_by!(critic: critic) do |rating|
          rating.skip_cache_average_ratings_callback = true
          rating.score = (rand(1.0..5.0) * 2).round / 2.0

          # ~30% of ratings get an impression (needed for "Best of Year" section)
          rating.impression = impressions.sample if rand(100) < 30
        end

        print "."
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Cache computed averages
  # ---------------------------------------------------------------------------
  puts "\n\nCaching average ratings..."
  Selection.find_each(&:cache_average_rating)
  Film.find_each(&:cache_overall_average_rating)

  # ---------------------------------------------------------------------------
  # Link podcast episodes to editions
  # ---------------------------------------------------------------------------
  puts "\nLinking podcast episodes to editions..."

  podcast_editions = [past_edition, past_edition_2, current_edition]
  podcast.episodes.order(:published_at).each_with_index do |episode, i|
    if podcast_editions[i]
      episode.update!(edition: podcast_editions[i])
      puts "   #{episode.title} → #{podcast_editions[i].code}"
    end
  end

  # ---------------------------------------------------------------------------
  # Generate YearInReview (populates "Best of Year" homepage section)
  # ---------------------------------------------------------------------------
  puts "\nGenerating Year in Review for #{last_year}..."
  yir_prev = YearInReview.for(last_year)
  puts "   #{yir_prev.editions_count} editions, #{yir_prev.films_count} films, #{yir_prev.ratings_count} ratings"
  puts "   Top #{yir_prev.year_in_review_top_selections.count} films selected"

  puts "\nGenerating Year in Review for #{this_year}..."
  yir = YearInReview.for(this_year)
  puts "   #{yir.editions_count} editions, #{yir.films_count} films, #{yir.ratings_count} ratings"
  puts "   Top #{yir.year_in_review_top_selections.count} films selected"

  # ---------------------------------------------------------------------------
  # Summary
  # ---------------------------------------------------------------------------
  puts "\n#{"=" * 60}"
  puts "SEED COMPLETE — Homepage section coverage:"
  puts "=" * 60
  puts "  Live Now:        #{Edition.current.count} edition(s)"
  puts "  Best of #{this_year}:    #{yir.year_in_review_top_selections.count} top film(s)"
  puts "  Year in Review #{last_year}: #{yir_prev.year_in_review_top_selections.count} top film(s), #{yir_prev.editions_count} editions"
  puts "  Recent Festival: #{Edition.past.where("CAST(strftime('%Y', end_date) AS INTEGER) = ?", this_year).first&.code || "N/A"}"
  puts "  Podcast:         #{podcast.episodes.count} episode(s)"
  puts "  Coming Soon:     #{Edition.upcoming.count} edition(s)"
  puts "  Recent Coverage: #{Edition.past.where("CAST(strftime('%Y', start_date) AS INTEGER) = ?", this_year).count} edition(s)"
  puts "=" * 60
  puts "\nDone. Run: bin/dev and visit http://localhost:3000\n\n"
end
