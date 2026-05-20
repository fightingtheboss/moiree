# frozen_string_literal: true

namespace :films do
  desc <<~DESC
    Search TMDB for a curated list of real festival films and print a Ruby array
    literal suitable for pasting into SEED_FILMS in db/seeds.rb.

    Usage: bin/rails films:generate_seed_data
  DESC
  task generate_seed_data: :environment do
    films = [
      # Cannes
      { title: "Anatomy of a Fall",            year: 2023, director: "Justine Triet",                  country: "FR" },
      { title: "Fallen Leaves",                 year: 2023, director: "Aki Kaurismäki",                 country: "FI" },
      { title: "Monster",                       year: 2023, director: "Hirokazu Kore-eda",              country: "JP" },
      { title: "The Zone of Interest",          year: 2023, director: "Jonathan Glazer",                country: "GB" },
      { title: "May December",                  year: 2023, director: "Todd Haynes",                    country: "US" },
      { title: "Past Lives",                    year: 2023, director: "Celine Song",                    country: "US" },
      { title: "Triangle of Sadness",           year: 2022, director: "Ruben Östlund",                  country: "SE" },
      { title: "Crimes of the Future",          year: 2022, director: "David Cronenberg",               country: "CA" },
      { title: "Broker",                        year: 2022, director: "Hirokazu Kore-eda",              country: "KR" },
      { title: "EO",                            year: 2022, director: "Jerzy Skolimowski",              country: "PL" },
      { title: "Decision to Leave",             year: 2022, director: "Park Chan-wook",                 country: "KR" },
      { title: "Close",                         year: 2022, director: "Lukas Dhont",                    country: "BE" },
      { title: "Titane",                        year: 2021, director: "Julia Ducournau",                country: "FR" },
      { title: "Drive My Car",                  year: 2021, director: "Ryusuke Hamaguchi",              country: "JP" },
      { title: "Memoria",                       year: 2021, director: "Apichatpong Weerasethakul",      country: "TH" },
      { title: "Annette",                       year: 2021, director: "Leos Carax",                     country: "FR" },
      { title: "A Hero",                        year: 2021, director: "Asghar Farhadi",                 country: "IR" },
      { title: "Parasite",                      year: 2019, director: "Bong Joon-ho",                   country: "KR" },
      { title: "Portrait of a Lady on Fire",    year: 2019, director: "Céline Sciamma",                 country: "FR" },
      { title: "Pain and Glory",                year: 2019, director: "Pedro Almodóvar",                country: "ES" },
      { title: "Bacurau",                       year: 2019, director: "Kleber Mendonça Filho",          country: "BR" },
      { title: "The Lighthouse",                year: 2019, director: "Robert Eggers",                  country: "US" },
      { title: "Burning",                       year: 2018, director: "Lee Chang-dong",                 country: "KR" },
      { title: "Shoplifters",                   year: 2018, director: "Hirokazu Kore-eda",              country: "JP" },
      { title: "Happy as Lazzaro",              year: 2018, director: "Alice Rohrwacher",               country: "IT" },
      { title: "Cold War",                      year: 2018, director: "Paweł Pawlikowski",              country: "PL" },
      { title: "Capernaum",                     year: 2018, director: "Nadine Labaki",                  country: "LB" },
      { title: "The Square",                    year: 2017, director: "Ruben Östlund",                  country: "SE" },
      { title: "120 Beats Per Minute",          year: 2017, director: "Robin Campillo",                 country: "FR" },
      { title: "Loveless",                      year: 2017, director: "Andrey Zvyagintsev",             country: "RU" },
      # Venice
      { title: "The Brutalist",                 year: 2024, director: "Brady Corbet",                   country: "GB" },
      { title: "April",                         year: 2024, director: "Dea Kulumbegashvili",            country: "GE" },
      { title: "Babygirl",                      year: 2024, director: "Halina Reijn",                   country: "NL" },
      { title: "Queer",                         year: 2024, director: "Luca Guadagnino",                country: "IT" },
      { title: "The Room Next Door",            year: 2024, director: "Pedro Almodóvar",                country: "ES" },
      { title: "Maria",                         year: 2024, director: "Pablo Larraín",                  country: "CL" },
      { title: "Tár",                           year: 2022, director: "Todd Field",                     country: "US" },
      { title: "The Whale",                     year: 2022, director: "Darren Aronofsky",               country: "US" },
      { title: "Argentina, 1985",               year: 2022, director: "Santiago Mitre",                 country: "AR" },
      { title: "Saint Omer",                    year: 2022, director: "Alice Diop",                     country: "FR" },
      { title: "Bones and All",                 year: 2022, director: "Luca Guadagnino",                country: "IT" },
      { title: "White Noise",                   year: 2022, director: "Noah Baumbach",                  country: "US" },
      { title: "Spencer",                       year: 2021, director: "Pablo Larraín",                  country: "CL" },
      { title: "The Power of the Dog",          year: 2021, director: "Jane Campion",                   country: "NZ" },
      { title: "Parallel Mothers",              year: 2021, director: "Pedro Almodóvar",                country: "ES" },
      { title: "Nomadland",                     year: 2020, director: "Chloé Zhao",                     country: "US" },
      { title: "Pieces of a Woman",             year: 2020, director: "Kornél Mundruczó",               country: "HU" },
      { title: "Quo Vadis, Aida?",              year: 2020, director: "Jasmila Žbanić",                 country: "BA" },
      { title: "Joker",                         year: 2019, director: "Todd Phillips",                  country: "US" },
      # Berlin
      { title: "Small Things Like These",       year: 2024, director: "Tim Mielants",                   country: "BE" },
      { title: "A Different Man",               year: 2024, director: "Aaron Schimberg",                country: "US" },
      { title: "Dahomey",                       year: 2024, director: "Mati Diop",                      country: "FR" },
      { title: "Afire",                         year: 2023, director: "Christian Petzold",              country: "DE" },
      { title: "All Quiet on the Western Front", year: 2022, director: "Edward Berger",                 country: "DE" },
      { title: "Peter von Kant",                year: 2022, director: "François Ozon",                  country: "FR" },
      { title: "Hive",                          year: 2021, director: "Blerta Basholli",                country: "XK" },
      { title: "Bad Luck Banging or Loony Porn", year: 2021, director: "Radu Jude",                    country: "RO" },
      { title: "Synonyms",                      year: 2019, director: "Nadav Lapid",                    country: "IL" },
      { title: "On Body and Soul",              year: 2017, director: "Ildikó Enyedi",                  country: "HU" },
      # Sundance
      { title: "A Real Pain",                   year: 2024, director: "Jesse Eisenberg",                country: "US" },
      { title: "Love Lies Bleeding",            year: 2024, director: "Rose Glass",                     country: "GB" },
      { title: "Didi",                          year: 2024, director: "Sean Wang",                      country: "US" },
      { title: "Thelma",                        year: 2024, director: "Josh Margolin",                  country: "US" },
      { title: "Sometimes I Think About Dying", year: 2023, director: "Rachel Lambert",                 country: "US" },
      { title: "CODA",                          year: 2021, director: "Siân Heder",                     country: "US" },
      { title: "Passing",                       year: 2021, director: "Rebecca Hall",                   country: "GB" },
      { title: "Never Rarely Sometimes Always", year: 2020, director: "Eliza Hittman",                  country: "US" },
      { title: "Minari",                        year: 2020, director: "Lee Isaac Chung",                country: "US" },
      { title: "The Farewell",                  year: 2019, director: "Lulu Wang",                      country: "US" },
      { title: "Honey Boy",                     year: 2019, director: "Alma Har'el",                    country: "US" },
      # Toronto
      { title: "Conclave",                      year: 2024, director: "Edward Berger",                  country: "GB" },
      { title: "The Apprentice",                year: 2024, director: "Ali Abbasi",                     country: "DK" },
      { title: "We Live in Time",               year: 2024, director: "John Crowley",                   country: "GB" },
      { title: "Sing Sing",                     year: 2024, director: "Greg Kwedar",                    country: "US" },
      { title: "Nickel Boys",                   year: 2024, director: "RaMell Ross",                    country: "US" },
      { title: "Emilia Pérez",                  year: 2024, director: "Jacques Audiard",                country: "FR" },
      { title: "The Substance",                 year: 2024, director: "Coralie Fargeat",                country: "FR" },
      { title: "Women Talking",                 year: 2022, director: "Sarah Polley",                   country: "CA" },
      { title: "The Banshees of Inisherin",     year: 2022, director: "Martin McDonagh",                country: "IE" },
      { title: "The Fabelmans",                 year: 2022, director: "Steven Spielberg",               country: "US" },
      { title: "Belfast",                       year: 2021, director: "Kenneth Branagh",                country: "GB" },
      { title: "Mass",                          year: 2021, director: "Fran Kranz",                     country: "US" },
      { title: "Flee",                          year: 2021, director: "Jonas Poher Rasmussen",          country: "DK" },
      { title: "The Father",                    year: 2020, director: "Florian Zeller",                 country: "GB" },
      { title: "Promising Young Woman",         year: 2020, director: "Emerald Fennell",                country: "GB" },
      { title: "Marriage Story",                year: 2019, director: "Noah Baumbach",                  country: "US" },
      { title: "Once Upon a Time in Hollywood", year: 2019, director: "Quentin Tarantino",              country: "US" },
      # Additional
      { title: "Aftersun",                      year: 2022, director: "Charlotte Wells",                country: "GB" },
      { title: "Everything Everywhere All at Once", year: 2022, director: "Daniel Kwan",               country: "US" },
      { title: "After Yang",                    year: 2022, director: "Kogonada",                       country: "US" },
      { title: "Return to Seoul",               year: 2022, director: "Davy Chou",                      country: "FR" },
      { title: "The Worst Person in the World", year: 2021, director: "Joachim Trier",                  country: "NO" },
      { title: "Petite Maman",                  year: 2021, director: "Céline Sciamma",                 country: "FR" },
      { title: "Wheel of Fortune and Fantasy",  year: 2021, director: "Ryusuke Hamaguchi",              country: "JP" },
      { title: "Compartment No. 6",             year: 2021, director: "Juho Kuosmanen",                 country: "FI" },
      { title: "Happening",                     year: 2021, director: "Audrey Diwan",                   country: "FR" },
      { title: "First Cow",                     year: 2019, director: "Kelly Reichardt",                country: "US" },
    ]

    $stderr.puts "Searching TMDB for #{films.count} films...\n\n"

    results = []
    not_found = []

    films.each do |film|
      match = TMDB.search(film[:title], year: film[:year]).first

      if match&.poster_path.present?
        results << film.merge(
          tmdb_id:       match.id,
          poster_path:   match.poster_path,
          backdrop_path: match.backdrop_path,
        )
        $stderr.puts "  ✓ #{film[:title]} (#{film[:year]})"
      else
        not_found << film
        $stderr.puts "  ✗ #{film[:title]} (#{film[:year]}) — no result"
      end

      sleep 0.25
    end

    puts "SEED_FILMS = ["
    results.each do |f|
      puts "  { title: #{f[:title].inspect}, year: #{f[:year]}, director: #{f[:director].inspect}, country: #{f[:country].inspect}, tmdb_id: #{f[:tmdb_id]}, poster_path: #{f[:poster_path].inspect}, backdrop_path: #{f[:backdrop_path].inspect} },"
    end
    puts "].freeze"

    $stderr.puts "\nDone — #{results.count} found, #{not_found.count} not found."
    $stderr.puts "Paste the output above into db/seeds.rb, replacing the SEED_FILMS placeholder." if not_found.empty?
  end
end
