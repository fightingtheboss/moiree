# frozen_string_literal: true

class RecomputeFilmSortTitlesForAdditionalArticles < ActiveRecord::Migration[7.1]
  IGNORED_LEADING_ARTICLES =
    /\A(?:(?:the|a|an|le|la|les|un|une|des|el|los|las|unos|unas|il|lo|gli|uno|una)\s+|(?:l|un)['’])/

  def up
    Film.find_each do |film|
      sort_title = I18n.transliterate(film.title).downcase.sub(IGNORED_LEADING_ARTICLES, "")
      film.update_column(:sort_title, sort_title)
    end
  end

  def down
    # sort_title is derived data; there's nothing meaningful to restore.
  end
end
