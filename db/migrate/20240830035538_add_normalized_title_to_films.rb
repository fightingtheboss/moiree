class AddNormalizedTitleToFilms < ActiveRecord::Migration[7.1]
  def up
    add_column :films, :normalized_title, :string

    Film.find_each do |film|
      film.update(normalized_title: I18n.transliterate(film.title))
    end

    change_column_null :films, :normalized_title, false
  end

  def down
    remove_column :films, :normalized_title
  end
end
