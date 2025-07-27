# frozen_string_literal: true

class Film::Normalizers::Country
  def call(country)
    codes = country.split(",").map(&:strip).map do |c|
      country_obj = Country[c] || Country.find_country_by_any_name(c)
      country_obj&.alpha2 || c
    end

    codes.join(",")
  end
end
