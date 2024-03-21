# frozen_string_literal: true

class Admin
  module FestivalsHelper
    def countries_select
      Country.all.map { |c| "#{c.common_name} #{c.emoji_flag}" }.zip(Country.all.map(&:alpha2)).sort
    end
  end
end
