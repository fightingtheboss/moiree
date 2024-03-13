class CreateFestivals < ActiveRecord::Migration[7.1]
  def change
    create_table :festivals do |t|
      t.string :name
      t.string :short_name
      t.string :url
      t.string :code
      t.integer :year
      t.string :country
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
