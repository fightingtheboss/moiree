# frozen_string_literal: true

class Admin
  module FestivalsHelper
    def countries_select
      Country.all.map { |c| "#{c.emoji_flag} #{c.common_name}" }.zip(Country.all.map(&:alpha2)).sort do |a, b|
        a[0][3, 100] <=> b[0][3, 100]
      end
    end
  end
end
