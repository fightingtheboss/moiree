# frozen_string_literal: true

class AddSortTitleToFilms < ActiveRecord::Migration[7.1]
  IGNORED_LEADING_ARTICLES =
    /\A(?:(?:the|a|an|le|la|les|un|une|des|el|los|las|unos|unas|il|lo|gli|uno|una)\s+|(?:l|un)['’])/

  def up
    add_column(:films, :sort_title, :string)
    add_index(:films, :sort_title)

    Film.find_each do |film|
      sort_title = I18n.transliterate(film.title).downcase.sub(IGNORED_LEADING_ARTICLES, "")
      film.update_column(:sort_title, sort_title)
    end

    change_column_null(:films, :sort_title, false)
  end

  def down
    remove_column(:films, :sort_title)
  end
end
