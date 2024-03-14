class CreateFestivals < ActiveRecord::Migration[7.1]
  def change
    create_table :festivals do |t|
      t.string :name
      t.string :short_name
      t.string :url
      t.string :country

      t.timestamps
    end
  end
end
