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
  # Films — real festival films with TMDB data for poster support.
  # Generate this constant by running: bin/rails films:generate_seed_data
  # Paste the output here, then delete lib/tasks/generate_seed_films.rake.
  # ---------------------------------------------------------------------------
  SEED_FILMS = [
    { title: "Anatomy of a Fall", year: 2023, director: "Justine Triet", country: "FR", tmdb_id: 915935, poster_path: "/1ho0d4LNZw3Y0voeKmSvPSgJOJ2.jpg", backdrop_path: "/lDVl2jf6VB8ODl1olZ6FLvOV1gX.jpg" },
    { title: "Fallen Leaves", year: 2023, director: "Aki Kaurismäki", country: "FI", tmdb_id: 986280, poster_path: "/9ayYOpeqHhxfHHUoyt3kXzznECO.jpg", backdrop_path: "/cru4rjGcdHGhnPyjNXvW82jOrif.jpg" },
    { title: "Monster", year: 2023, director: "Hirokazu Kore-eda", country: "JP", tmdb_id: 1050035, poster_path: "/kvUJUyUGOhEoiWWNH04IXoExPE2.jpg", backdrop_path: "/dZJcOyRonN0Kb7kJR3DE3esGn16.jpg" },
    { title: "The Zone of Interest", year: 2023, director: "Jonathan Glazer", country: "GB", tmdb_id: 467244, poster_path: "/hUu9zyZmDd8VZegKi1iK1Vk0RYS.jpg", backdrop_path: "/pnTSOKcYnvdpQNQElAtJM1rWOxH.jpg" },
    { title: "May December", year: 2023, director: "Todd Haynes", country: "US", tmdb_id: 839369, poster_path: "/zhV7B610l7hjlri4ywikJ18ONuq.jpg", backdrop_path: "/97MOhHIgU6ZdLcB9DrAhx3WAqrU.jpg" },
    { title: "Past Lives", year: 2023, director: "Celine Song", country: "US", tmdb_id: 666277, poster_path: "/k3waqVXSnvCZWfJYNtdamTgTtTA.jpg", backdrop_path: "/7HR38hMBl23lf38MAN63y4pKsHz.jpg" },
    { title: "Triangle of Sadness", year: 2022, director: "Ruben Östlund", country: "SE", tmdb_id: 497828, poster_path: "/k9eLozCgCed5FGTSdHu0bBElAV8.jpg", backdrop_path: "/vNPY4oCSUp7CxbHkKJNRx1fmCl0.jpg" },
    { title: "Crimes of the Future", year: 2022, director: "David Cronenberg", country: "CA", tmdb_id: 819876, poster_path: "/RAFYMC0NgK9In9aGY6k6wsIL8w.jpg", backdrop_path: "/sqdsuvy8X6Maila4IAc7deMtPAA.jpg" },
    { title: "Broker", year: 2022, director: "Hirokazu Kore-eda", country: "KR", tmdb_id: 736732, poster_path: "/x86xaUnxU31JYiwlO35corDEV1i.jpg", backdrop_path: "/dom8lzl2iU46nDu6s4lBolBNjQs.jpg" },
    { title: "EO", year: 2022, director: "Jerzy Skolimowski", country: "PL", tmdb_id: 785398, poster_path: "/1MK86Vr2nf1GSYOtRd8pFvA5RM8.jpg", backdrop_path: "/bdncpEiiH3C7OjzvIu07zl2zcTd.jpg" },
    { title: "Decision to Leave", year: 2022, director: "Park Chan-wook", country: "KR", tmdb_id: 705996, poster_path: "/zI8KZ4EdLUymWKX1YEkpZ0gtPUa.jpg", backdrop_path: "/A1bWhTFQKkhF1yhSKWosSyzn2Hp.jpg" },
    { title: "Close", year: 2022, director: "Lukas Dhont", country: "BE", tmdb_id: 901563, poster_path: "/dlMNnWs7Mz8Nk5AC447Ew1tD5pn.jpg", backdrop_path: "/saESlYSTAGjr8gkyjoGb7omH0hf.jpg" },
    { title: "Titane", year: 2021, director: "Julia Ducournau", country: "FR", tmdb_id: 630240, poster_path: "/mBlpouG3gqB8WLdP65LCOXb3jFb.jpg", backdrop_path: "/dVOlJVHYRWx7DhMQRNLnbf5bT1q.jpg" },
    { title: "Drive My Car", year: 2021, director: "Ryusuke Hamaguchi", country: "JP", tmdb_id: 758866, poster_path: "/a2lxHS6Au35k5XtFQEQW44yWHeH.jpg", backdrop_path: "/r6aqhlmJmu8Dv5E7QYEruaEXKYm.jpg" },
    { title: "Memoria", year: 2021, director: "Apichatpong Weerasethakul", country: "TH", tmdb_id: 511819, poster_path: "/uZ4GABzjCIiQNlYSgjXoaf6rpK5.jpg", backdrop_path: "/nvTD2DO96mEwOga34lQZgBKpdEQ.jpg" },
    { title: "Annette", year: 2021, director: "Leos Carax", country: "FR", tmdb_id: 424277, poster_path: "/4FTnypxpGltJdIARrfFsP31pGTp.jpg", backdrop_path: "/cDVWsqsnGwIUqOSzAuDS0PIhNdW.jpg" },
    { title: "A Hero", year: 2021, director: "Asghar Farhadi", country: "IR", tmdb_id: 672208, poster_path: "/5VBPRWW13OJoiLA6suLofnjLKou.jpg", backdrop_path: "/rXRf5Okqg0FzDpmZkt4wly2asB2.jpg" },
    { title: "Parasite", year: 2019, director: "Bong Joon-ho", country: "KR", tmdb_id: 496243, poster_path: "/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg", backdrop_path: "/TU9NIjwzjoKPwQHoHshkFcQUCG.jpg" },
    { title: "Portrait of a Lady on Fire", year: 2019, director: "Céline Sciamma", country: "FR", tmdb_id: 531428, poster_path: "/2LquGwEhbg3soxSCs9VNyh5VJd9.jpg", backdrop_path: "/foFq1RZWQIgFuCQ0nyYccywjFyX.jpg" },
    { title: "Pain and Glory", year: 2019, director: "Pedro Almodóvar", country: "ES", tmdb_id: 519010, poster_path: "/cMlueArJXXwZbeLpb4NhC3pxmBk.jpg", backdrop_path: "/o1JapnInSBCgedfWnj15ytjGC70.jpg" },
    { title: "Bacurau", year: 2019, director: "Kleber Mendonça Filho", country: "BR", tmdb_id: 446159, poster_path: "/tBa4zMGzZUco26XT3WfZZCwQ76i.jpg", backdrop_path: "/nhsC7Q1Zb5n2p4H3UKy422zP5XC.jpg" },
    { title: "The Lighthouse", year: 2019, director: "Robert Eggers", country: "US", tmdb_id: 503919, poster_path: "/f1tIYarTbkBdIT1aW0gzelDwknv.jpg", backdrop_path: "/sYLzRuEcwSz0L1Z92wQNrETHU9O.jpg" },
    { title: "Burning", year: 2018, director: "Lee Chang-dong", country: "KR", tmdb_id: 491584, poster_path: "/kXiF80o74fE9gf3Utf9moAI7ar0.jpg", backdrop_path: "/qQEt2FqF8McryFBNX30dyDJKiEK.jpg" },
    { title: "Shoplifters", year: 2018, director: "Hirokazu Kore-eda", country: "JP", tmdb_id: 505192, poster_path: "/4nfRUOv3LX5zLn98WS1WqVBk9E9.jpg", backdrop_path: "/k49RhOmaKfoybjR3vBSaOJrIGmc.jpg" },
    { title: "Happy as Lazzaro", year: 2018, director: "Alice Rohrwacher", country: "IT", tmdb_id: 481432, poster_path: "/j4x1O6G0cbchHQwNsEZ0DntOJMJ.jpg", backdrop_path: "/zTnpY0BXP6ytvV4ZMsAmsIEDmNM.jpg" },
    { title: "Cold War", year: 2018, director: "Paweł Pawlikowski", country: "PL", tmdb_id: 440298, poster_path: "/6rbS8oPIgUMhQgIX8oGVTtlNgLR.jpg", backdrop_path: "/dXwXcBGK8LJ6UQVvuWM3qG6m6Co.jpg" },
    { title: "Capernaum", year: 2018, director: "Nadine Labaki", country: "LB", tmdb_id: 517814, poster_path: "/mFnfTVADj8yOxwzprYOmTPselk8.jpg", backdrop_path: "/sEW8q9al73rtow257dXAusD9yS7.jpg" },
    { title: "The Square", year: 2017, director: "Ruben Östlund", country: "SE", tmdb_id: 401246, poster_path: "/pefcv5VNspSK4Dt8doei5bJmmln.jpg", backdrop_path: "/bYZM4DoHrmzY3oq2qrcXAYQmLNp.jpg" },
    { title: "120 Beats Per Minute", year: 2017, director: "Robin Campillo", country: "FR", tmdb_id: 451945, poster_path: "/azLtGx5ZhdTSP2b4oNLWtiE51OW.jpg", backdrop_path: "/1pyUrlbTVCkGkcu7LsGMqxuCtkP.jpg" },
    { title: "Loveless", year: 2017, director: "Andrey Zvyagintsev", country: "RU", tmdb_id: 429174, poster_path: "/oBUsLGZoGuLKMuHj19mjG9iCDoq.jpg", backdrop_path: "/fnWEr4voDR1kp0sXZ1WufM7j2Qp.jpg" },
    { title: "The Brutalist", year: 2024, director: "Brady Corbet", country: "GB", tmdb_id: 549509, poster_path: "/vP7Yd6couiAaw9jgMd5cjMRj3hQ.jpg", backdrop_path: "/hmZnqijPaaACjenDkrbWcCmcADI.jpg" },
    { title: "April", year: 2024, director: "Dea Kulumbegashvili", country: "GE", tmdb_id: 1064021, poster_path: "/9DJadZoQfmSzxe3E5uB7dISfc3L.jpg", backdrop_path: "/5DLUByGgl2UXOn00UHvbnaIk34F.jpg" },
    { title: "Babygirl", year: 2024, director: "Halina Reijn", country: "NL", tmdb_id: 1097549, poster_path: "/ilwO6elz3mLV9CToT7C8pjVeKX0.jpg", backdrop_path: "/s7vWRjcfRVMW8tBIxhC3UhKxRoo.jpg" },
    { title: "Queer", year: 2024, director: "Luca Guadagnino", country: "IT", tmdb_id: 1059128, poster_path: "/xe4b2TMciLKA1C0JlhWxb4ENLln.jpg", backdrop_path: "/7bUYzlDz8eel1BVL1Y0YcF9NQmd.jpg" },
    { title: "The Room Next Door", year: 2024, director: "Pedro Almodóvar", country: "ES", tmdb_id: 1088514, poster_path: "/qMibLyArrlBJ87AoqQBeVaFeRXp.jpg", backdrop_path: "/9Xx0BCkxDsF47niAPsb8lQ0O9Qu.jpg" },
    { title: "Maria", year: 2024, director: "Pablo Larraín", country: "CL", tmdb_id: 1038263, poster_path: "/3oQRG0bwPUqE4N4n8z2kAzr7e40.jpg", backdrop_path: "/9iw4a6AQkxUO3EuRn59Vgrqf0zO.jpg" },
    { title: "Tár", year: 2022, director: "Todd Field", country: "US", tmdb_id: 817758, poster_path: "/dRVAlaU0vbG6hMf2K45NSiIyoUe.jpg", backdrop_path: "/84XcRwKHAw4VXdKOYTSW5ARxFEt.jpg" },
    { title: "The Whale", year: 2022, director: "Darren Aronofsky", country: "US", tmdb_id: 785084, poster_path: "/jQ0gylJMxWSL490sy0RrPj1Lj7e.jpg", backdrop_path: "/46FRuCeAn6TrS4F1P4F9zhyCpyo.jpg" },
    { title: "Argentina, 1985", year: 2022, director: "Santiago Mitre", country: "AR", tmdb_id: 714888, poster_path: "/nmh7vD2eDVRqFJoCpEzVcfGcPPf.jpg", backdrop_path: "/gh1Rghpf3BIISHSAw9GsObG4TN3.jpg" },
    { title: "Saint Omer", year: 2022, director: "Alice Diop", country: "FR", tmdb_id: 925943, poster_path: "/ekr25uuxlH7kg3KLhLLZcDZ15xd.jpg", backdrop_path: "/aX1VH6SowCM3IezI09VqZjIuWiS.jpg" },
    { title: "Bones and All", year: 2022, director: "Luca Guadagnino", country: "IT", tmdb_id: 791177, poster_path: "/dBQuk2LkHjrDsSjueirPQg96GCc.jpg", backdrop_path: "/8sPxa4sdRvjgRG3GgkO8RQxUR9P.jpg" },
    { title: "White Noise", year: 2022, director: "Noah Baumbach", country: "US", tmdb_id: 744594, poster_path: "/kesxNdLZlmGoTRspDHU1WgdEuGw.jpg", backdrop_path: "/4QB2TfxmzgMDLmsVVk1HM4tt7ef.jpg" },
    { title: "Spencer", year: 2021, director: "Pablo Larraín", country: "CL", tmdb_id: 716612, poster_path: "/7GcqdBKaMM9BWXWN07BirBMkcBF.jpg", backdrop_path: "/67qC43OXQESGJCYg7IJHN5F66X0.jpg" },
    { title: "The Power of the Dog", year: 2021, director: "Jane Campion", country: "NZ", tmdb_id: 600583, poster_path: "/kEy48iCzGnp0ao1cZbNeWR6yIhC.jpg", backdrop_path: "/gAsHuCQMN7mv4uFIvM4ACQ09hPr.jpg" },
    { title: "Parallel Mothers", year: 2021, director: "Pedro Almodóvar", country: "ES", tmdb_id: 766798, poster_path: "/gDaxYkYNbHuM2VlUazbcpnFZB6d.jpg", backdrop_path: "/w81qHqr1CdbdRco8jpmu6lXMqyk.jpg" },
    { title: "Nomadland", year: 2020, director: "Chloé Zhao", country: "US", tmdb_id: 581734, poster_path: "/dKT8rGDR55cM1vGn7QZLA9Tg9YC.jpg", backdrop_path: "/563sRDK3rZS31TXCdTY4lfcwrNK.jpg" },
    { title: "Pieces of a Woman", year: 2020, director: "Kornél Mundruczó", country: "HU", tmdb_id: 641662, poster_path: "/OgUfLlhfBFx5BPK6LzBWFvBW1w.jpg", backdrop_path: "/izNpxVcjKbF9BiYF4GVqxCOfewL.jpg" },
    { title: "Quo Vadis, Aida?", year: 2020, director: "Jasmila Žbanić", country: "BA", tmdb_id: 728118, poster_path: "/eQy2Tgvmx0FkK8vMMqMW4aX5UXQ.jpg", backdrop_path: "/awElIr61fFpbudzlCfobIpbwEro.jpg" },
    { title: "Joker", year: 2019, director: "Todd Phillips", country: "US", tmdb_id: 475557, poster_path: "/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg", backdrop_path: "/hO7KbdvGOtDdeg0W4Y5nKEHeDDh.jpg" },
    { title: "Small Things Like These", year: 2024, director: "Tim Mielants", country: "BE", tmdb_id: 1102493, poster_path: "/rdcO38cbWFg002nXg5QYtk7Tz4L.jpg", backdrop_path: "/rtpFIgy1YYw3kx7PCyNhi6xmEFb.jpg" },
    { title: "A Different Man", year: 2024, director: "Aaron Schimberg", country: "US", tmdb_id: 989662, poster_path: "/lZZKTEvo92u1J5pm7QoEA5yN3du.jpg", backdrop_path: "/xSqaVqkbeSaPmeEyurWBaTSkgL9.jpg" },
    { title: "Dahomey", year: 2024, director: "Mati Diop", country: "FR", tmdb_id: 1101256, poster_path: "/9d8KvJ3OjUq9rwuM743QPQO48aL.jpg", backdrop_path: "/gtIr9Cy7yIdgzVJdBSnaf2AgzlV.jpg" },
    { title: "Afire", year: 2023, director: "Christian Petzold", country: "DE", tmdb_id: 900379, poster_path: "/k8NYzD01zAUsdqocjhLXbO9BSS8.jpg", backdrop_path: "/wbW4w4HvvzDavQCjUKtLMosyNn5.jpg" },
    { title: "All Quiet on the Western Front", year: 2022, director: "Edward Berger", country: "DE", tmdb_id: 49046, poster_path: "/2IRjbi9cADuDMKmHdLK7LaqQDKA.jpg", backdrop_path: "/xBwtP27cx8WfjHJVFkpuV6F1RES.jpg" },
    { title: "Peter von Kant", year: 2022, director: "François Ozon", country: "FR", tmdb_id: 807862, poster_path: "/5ZTjS0XmJHCAcp0jWj6tR64hAeJ.jpg", backdrop_path: "/iozxwgTMgaqljPfZ5fE7913mLU.jpg" },
    { title: "Hive", year: 2021, director: "Blerta Basholli", country: "XK", tmdb_id: 776541, poster_path: "/tpIVRbbWM6wvpugYrKvQPY2NQyJ.jpg", backdrop_path: "/4j78JEMgJaFWwR3lXbXNPFpqjcb.jpg" },
    { title: "Bad Luck Banging or Loony Porn", year: 2021, director: "Radu Jude", country: "RO", tmdb_id: 790496, poster_path: "/zUTkjET8VUwvbvSHtn0Lou7xwyZ.jpg", backdrop_path: "/wP28rWRjcD1994uSLXAg0MZmUK7.jpg" },
    { title: "Synonyms", year: 2019, director: "Nadav Lapid", country: "IL", tmdb_id: 501590, poster_path: "/4Jh2h0XsUBFxxeRgDUdfrDjVgFz.jpg", backdrop_path: "/qTH5puD1XDO8iL2uPcDmxnvO6jJ.jpg" },
    { title: "On Body and Soul", year: 2017, director: "Ildikó Enyedi", country: "HU", tmdb_id: 436343, poster_path: "/uguWEoZelSSckxgiQctlkZ6gpfU.jpg", backdrop_path: "/s5BvDOLava3Z8NjAOnT0Xe96iLS.jpg" },
    { title: "A Real Pain", year: 2024, director: "Jesse Eisenberg", country: "US", tmdb_id: 1013850, poster_path: "/67xRIXm5TxXRT4nV2V4AEJ9yq2d.jpg", backdrop_path: "/fViElUGfdoZjtnVxvSpJX8TwxY6.jpg" },
    { title: "Love Lies Bleeding", year: 2024, director: "Rose Glass", country: "GB", tmdb_id: 948549, poster_path: "/xImj8RLe39YK0lyVu9kXv7ApN8p.jpg", backdrop_path: "/oMiKHO3H5RixfLsiU5Vumhlp5sj.jpg" },
    { title: "Didi", year: 2024, director: "Sean Wang", country: "US", tmdb_id: 1158915, poster_path: "/3UCTNaZgxW6BbeHMMTe6uL07MpV.jpg", backdrop_path: "/jD1oLRnLSKiLhutjiZ6OzgCgBsr.jpg" },
    { title: "Thelma", year: 2024, director: "Josh Margolin", country: "US", tmdb_id: 1541, poster_path: "/gQSUVGR80RVHxJywtwXm2qa1ebi.jpg", backdrop_path: "/eA15zhxnhQSg4k5MUbbTERIU23Z.jpg" },
    { title: "Sometimes I Think About Dying", year: 2023, director: "Rachel Lambert", country: "US", tmdb_id: 891933, poster_path: "/lp0dtmNtOW88A13GZjGoKZko7S8.jpg", backdrop_path: "/eRPBnjLwOM6jgXseWiAgAkgURHL.jpg" },
    { title: "CODA", year: 2021, director: "Siân Heder", country: "US", tmdb_id: 776503, poster_path: "/BzVjmm8l23rPsijLiNLUzuQtyd.jpg", backdrop_path: "/v85FlkbMYKa5du1glm0YfYNsL2n.jpg" },
    { title: "Passing", year: 2021, director: "Rebecca Hall", country: "GB", tmdb_id: 541524, poster_path: "/t4tYUT1oSWOP6XKZBoclPAG96KP.jpg", backdrop_path: "/7mH9nwyEyiGrODuq1khFEXyk5iY.jpg" },
    { title: "Never Rarely Sometimes Always", year: 2020, director: "Eliza Hittman", country: "US", tmdb_id: 595671, poster_path: "/7yiSyQhhjTFphhfCUcn05tCQxyG.jpg", backdrop_path: "/x4FX4WsadBDbHaxfNuPvIISF8YQ.jpg" },
    { title: "Minari", year: 2020, director: "Lee Isaac Chung", country: "US", tmdb_id: 615643, poster_path: "/6mPNdmjdbVKPITv3LLCmQoKs9Zw.jpg", backdrop_path: "/bKCpRjjTKcr3KAITmwjVMobbBYg.jpg" },
    { title: "The Farewell", year: 2019, director: "Lulu Wang", country: "US", tmdb_id: 565310, poster_path: "/7ht2IMGynDSVQGvAXhAb83DLET8.jpg", backdrop_path: "/5INPBiKVRsyp9kgHfsC0cTfvKFH.jpg" },
    { title: "Honey Boy", year: 2019, director: "Alma Har'el", country: "US", tmdb_id: 512263, poster_path: "/3BZ2rBn31kWER45ZMj7OTe9keMm.jpg", backdrop_path: "/4oQlzl5JsnmUF14LCNacOm9PUVl.jpg" },
    { title: "Conclave", year: 2024, director: "Edward Berger", country: "GB", tmdb_id: 974576, poster_path: "/vYEyxF1UT779RiEalpMjUT6kfdf.jpg", backdrop_path: "/eZzNdjNDvaSoyywy9ICg2UmFwul.jpg" },
    { title: "The Apprentice", year: 2024, director: "Ali Abbasi", country: "DK", tmdb_id: 1182047, poster_path: "/549Hdul2BgPnZMhqFxp6npp2opr.jpg", backdrop_path: "/kv9xVrxfLpudBLyYf1QvLCpUQuy.jpg" },
    { title: "We Live in Time", year: 2024, director: "John Crowley", country: "GB", tmdb_id: 1100099, poster_path: "/oeDNBgnlGF6rnyX1P1K8Vl2f3lW.jpg", backdrop_path: "/4t8IXJF4umwCfbdpeKLvlN3zkKp.jpg" },
    { title: "Sing Sing", year: 2024, director: "Greg Kwedar", country: "US", tmdb_id: 1155828, poster_path: "/s0TPyI8QlMiktEiq3JVhea0zFhM.jpg", backdrop_path: "/CZyMhVVpraYDptLpYXxXjgAuCH.jpg" },
    { title: "Nickel Boys", year: 2024, director: "RaMell Ross", country: "US", tmdb_id: 1028196, poster_path: "/lu2vmmtStmTNMmSZl2LgrrQpLZo.jpg", backdrop_path: "/kmLssINCNdXnIDjWkBsk6LUNSbe.jpg" },
    { title: "Emilia Pérez", year: 2024, director: "Jacques Audiard", country: "FR", tmdb_id: 974950, poster_path: "/7seqaCaaXDNUHOx4DqwpoOH8pPa.jpg", backdrop_path: "/u2eA9pqi1q3DvevT7RuDuJHxxBT.jpg" },
    { title: "The Substance", year: 2024, director: "Coralie Fargeat", country: "FR", tmdb_id: 933260, poster_path: "/lqoMzCcZYEFK729d6qzt349fB4o.jpg", backdrop_path: "/8ODNt5olCeIqBYTP3GgXEQYTfeX.jpg" },
    { title: "Women Talking", year: 2022, director: "Sarah Polley", country: "CA", tmdb_id: 777245, poster_path: "/wcTc9GveMMjAdHSlzdE0FaRCtqi.jpg", backdrop_path: "/edH2sKM63YiSEOWoaJPN87a71dZ.jpg" },
    { title: "The Banshees of Inisherin", year: 2022, director: "Martin McDonagh", country: "IE", tmdb_id: 674324, poster_path: "/4yFG6cSPaCaPhyJ1vtGOtMD1lgh.jpg", backdrop_path: "/1vXD5HXqkhvsXFHE7KmCPZGPR1e.jpg" },
    { title: "The Fabelmans", year: 2022, director: "Steven Spielberg", country: "US", tmdb_id: 804095, poster_path: "/h7llKkqkkJtJrTOaDLuVeUYDQ7I.jpg", backdrop_path: "/xQyGkQ8ICa4lgifGr3oZjkm3AJ2.jpg" },
    { title: "Belfast", year: 2021, director: "Kenneth Branagh", country: "GB", tmdb_id: 777270, poster_path: "/3mInLZyPOVLsZRsBwNHi3UJXXnm.jpg", backdrop_path: "/l1Z9PLy8AXiqlZmFEgiGWeSFdSX.jpg" },
    { title: "Mass", year: 2021, director: "Fran Kranz", country: "US", tmdb_id: 423333, poster_path: "/c3MQ3YZKJadrH2Yv45i07qMHGPM.jpg", backdrop_path: "/cv6Nn8Yt9mgFoUSievEdW9JK82A.jpg" },
    { title: "Flee", year: 2021, director: "Jonas Poher Rasmussen", country: "DK", tmdb_id: 680813, poster_path: "/vlMIbqOpYG553J1kOJXA7mwQvE6.jpg", backdrop_path: "/CKGSEnFTpcxPJM5TzTFUJz53s.jpg" },
    { title: "The Father", year: 2020, director: "Florian Zeller", country: "GB", tmdb_id: 600354, poster_path: "/pr3bEQ517uMb5loLvjFQi8uLAsp.jpg", backdrop_path: "/h3weAFgg06GqchI2xDfufBgSFTj.jpg" },
    { title: "Promising Young Woman", year: 2020, director: "Emerald Fennell", country: "GB", tmdb_id: 582014, poster_path: "/73QoFJFmUrJfDG2EynFjNc5gJxk.jpg", backdrop_path: "/gESm6yc2MZpSXakgqLF0OlLaRn1.jpg" },
    { title: "Marriage Story", year: 2019, director: "Noah Baumbach", country: "US", tmdb_id: 492188, poster_path: "/2JRyCKaRKyJAVpsIHeLvPw5nHmw.jpg", backdrop_path: "/wDwQXLDUuiEaaiuWIDBpbqnwYGX.jpg" },
    { title: "Once Upon a Time in Hollywood", year: 2019, director: "Quentin Tarantino", country: "US", tmdb_id: 466272, poster_path: "/8j58iEBw9pOXFD2L0nt0ZXeHviB.jpg", backdrop_path: "/kKTPv9LKKs5L3oO1y5FNObxAPWI.jpg" },
    { title: "Aftersun", year: 2022, director: "Charlotte Wells", country: "GB", tmdb_id: 965150, poster_path: "/evKz85EKouVbIr51zy5fOtpNRPg.jpg", backdrop_path: "/4jdduww9j5RyzO4ITRcuBFhqNN1.jpg" },
    { title: "Everything Everywhere All at Once", year: 2022, director: "Daniel Kwan", country: "US", tmdb_id: 545611, poster_path: "/u68AjlvlutfEIcpmbYpKcdi09ut.jpg", backdrop_path: "/ss0Os3uWJfQAENILHZUdX8Tt1OC.jpg" },
    { title: "After Yang", year: 2022, director: "Kogonada", country: "US", tmdb_id: 585378, poster_path: "/qjEuDeKOhA7JqaaqhLSfoS9titb.jpg", backdrop_path: "/y8ZholsWIn4jR3JoDWOSSFY87vf.jpg" },
    { title: "Return to Seoul", year: 2022, director: "Davy Chou", country: "FR", tmdb_id: 952701, poster_path: "/uEz1pAW2r1tECDI8ipttabaLHhW.jpg", backdrop_path: "/ngsAuG8JYOiuwgGejN7xljgETNt.jpg" },
    { title: "The Worst Person in the World", year: 2021, director: "Joachim Trier", country: "NO", tmdb_id: 660120, poster_path: "/1NxGNQchGBTHXJ6RShLY1IlZqWn.jpg", backdrop_path: "/4oWU9FPOvjCE85DaHm4vo89Whpz.jpg" },
    { title: "Petite Maman", year: 2021, director: "Céline Sciamma", country: "FR", tmdb_id: 749004, poster_path: "/fxl2ARZO2vRfUGDfqSz2bostauE.jpg", backdrop_path: "/yuXZXuS4RCTnCYScrRWBCNz2ywB.jpg" },
    { title: "Wheel of Fortune and Fantasy", year: 2021, director: "Ryusuke Hamaguchi", country: "JP", tmdb_id: 795811, poster_path: "/z3xqVWOsetW6pSEgx1uiqXfzRet.jpg", backdrop_path: "/58IBSEDDSzOEFowz9qs9QbUZ8bg.jpg" },
    { title: "Compartment No. 6", year: 2021, director: "Juho Kuosmanen", country: "FI", tmdb_id: 588182, poster_path: "/3KUsYQmQXVCMrnGnQIoqkj5MJUP.jpg", backdrop_path: "/h0uGdJyZ5o74p0E600oKYyaoDhw.jpg" },
    { title: "Happening", year: 2021, director: "Audrey Diwan", country: "FR", tmdb_id: 793998, poster_path: "/f2lTAmLYpWpd8JxtJrMXFFGV9gZ.jpg", backdrop_path: "/gJUDmMfeoVopMNwWRmswWJQu4km.jpg" },
    { title: "First Cow", year: 2019, director: "Kelly Reichardt", country: "US", tmdb_id: 558582, poster_path: "/yS41crZ1i0fFxCQbuL7I1Y1VBwm.jpg", backdrop_path: "/8P3qur5Xh6dsH6xmZ1O2XS7vnc2.jpg" },
  ].freeze

  puts "\nCreating #{SEED_FILMS.count} films..."

  SEED_FILMS.each do |attrs|
    Film.find_or_create_by!(title: attrs[:title]) do |film|
      film.original_title = attrs[:title]
      film.director       = attrs[:director]
      film.country        = attrs[:country]
      film.year           = attrs[:year]
      film.tmdb_id        = attrs[:tmdb_id]
      film.poster_path    = attrs[:poster_path]
      film.backdrop_path  = attrs[:backdrop_path]
    end
    print "."
  end

  all_films = Film.all.to_a
  prev_year_films = Film.where(year: last_year).presence&.to_a || all_films
  current_year_films = Film.where(year: this_year).presence&.to_a || all_films

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
