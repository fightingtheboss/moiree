# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.find_or_create_by!(email: "mina@fightingtheboss.com") do |user|
  user.password = SecureRandom.base58
  user.verified = true
  user.userable = Admin.find_or_create_by!(username: "mina")
end

if Rails.env.development?
  puts "Seeding development database..."

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

  puts "\n\nCreating 5 festivals..."

  ["Cannes", "Sundance", "Venice", "Berlin", "Toronto"].each do |festival_name|
    Festival.find_or_create_by!(name: festival_name) do |festival|
      festival.short_name = festival_name[0..2].upcase
      festival.url = Faker::Internet.url
      festival.country = ISO3166::Country.codes.sample
    end

    print "."
  end

  puts "\n\nCreating 2 editions per festival..."

  Festival.all.each do |festival|
    2.times do |i|
      year = Date.current.year + i

      festival.editions.find_or_create_by!(year: year) do |edition|
        edition.code = festival.name + year.to_s[-2..-1]
        edition.start_date = Faker::Date.between(from: Date.new(year, 1, 1), to: Date.new(year, 12, 31))
        edition.end_date = edition.start_date + rand(7..14).days
      end
    end

    print "."
  end

  puts "\n\nCreating 100 films..."

  100.times do
    Film.find_or_create_by!(title: Faker::Movie.unique.title) do |film|
      film.original_title = [film.title, nil].sample
      film.director = Faker::Name.name
      film.country = ISO3166::Country.codes.sample
      film.year = rand(1900..Date.current.year)
      film.overall_average_rating = rand(0.0..5.0)
    end
  end

  puts "\n\nPopulating editions..."

  Edition.all.each do |edition|
    puts "\n\n-> #{edition.code}"
    print "--> Adding critics"

    Critic.all.sample(rand(8..20)).each do |critic|
      edition.attendances.find_or_create_by!(critic: critic)
      print "."
    end

    puts
    print "--> Creating categories"

    # Create up to 10 categories
    Faker::Hipster.words(number: rand(12) + 5, spaces_allowed: true).each do |category_name|
      edition.categories.find_or_create_by!(name: category_name.capitalize)
      print "."
    end

    puts
    print "--> Creating selections"
    # Create up to 50 selections
    (rand(50) + 15).times do
      edition.selections.find_or_create_by!(film: Film.all.sample) do |selection|
        selection.category = edition.categories.sample
      end

      print "."
    end

    puts
    print "--> Creating ratings"
    # Create ratings for up to 80% of selections
    edition.selections.each do |selection|
      edition.critics.each do |critic|
        next if rand(10) > 7

        selection.ratings.find_or_create_by!(critic: critic) do |rating|
          rating.skip_cache_average_ratings_callback = true
          rating.score = (rand(1.0..5.0) * 2).round / 2.0
        end

        print "."
      end
    end
  end

  Selection.find_each(&:cache_average_rating)
  Film.find_each(&:cache_overall_average_rating)

  puts "\n\nDone.\n\n"
end
