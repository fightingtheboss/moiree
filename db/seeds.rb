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
    (1..2).each do |i|
      year = 2023 + i

      festival.editions.find_or_create_by!(year: year) do |edition|
        edition.code = Faker::Alphanumeric.alpha(number: 6).upcase
        edition.start_date = Faker::Date.between(from: Date.new(year, 1, 1), to: Date.new(year, 12, 31))
        edition.end_date = edition.start_date + rand(7..14).days
      end
    end

    print "."
  end

  puts "\n\nPopulating editions..."

  Edition.all.each do |edition|
    puts "\n\n-> #{edition.code} #{edition.year}"
    print "--> Creating categories"

    # Create up to 10 categories
    Faker::Hipster.words(number: rand(10) + 1).each do |category_name|
      edition.categories.find_or_create_by!(name: category_name.capitalize)
      print "."
    end

    puts
    print "--> Creating films"
    # Create up to 20 films
    (1..20).each do |j|
      edition.films.find_or_create_by!(title: Faker::Movie.title) do |film|
        film.original_title = [Faker::Movie.title, nil].sample
        film.director = Faker::Name.name
        film.country = ISO3166::Country.codes.sample
        film.year = rand(1900..edition.year)
        film.overall_average_rating = rand(1.0..5.0)
      end

      print "."
    end

    puts
    print "--> Creating reviews"
    # Create up to 25 selections
    edition.selections.each do |selection|
      Critic.all.each do |critic|
        next if rand(10) > 7

        selection.ratings.find_or_create_by!(critic: critic) do |rating|
          rating.score = rand(1.0..5.0)
        end

        print "."
      end
    end
  end

  puts "\n\nDone.\n\n"
end
