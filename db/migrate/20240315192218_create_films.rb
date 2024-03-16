class CreateFilms < ActiveRecord::Migration[7.1]
  def change
    create_table :films do |t|
      t.string :title
      t.string :original_title
      t.string :director
      t.string :country
      t.integer :year
      t.decimal :overall_average_rating, precision: 2, scale: 1

      t.timestamps
    end
  end
end
