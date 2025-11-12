# frozen_string_literal: true

class AddTMDBFieldsToFilm < ActiveRecord::Migration[8.0]
  def change
    add_column(:films, :summary, :text)
    add_column(:films, :tmdb_id, :integer)
    add_column(:films, :release_date, :date)
    add_column(:films, :poster_path, :string)
    add_column(:films, :backdrop_path, :string)
  end
end
