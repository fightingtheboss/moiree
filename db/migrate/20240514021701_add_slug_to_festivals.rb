class AddSlugToFestivals < ActiveRecord::Migration[7.1]
  def change
    add_column :festivals, :slug, :string
    add_index :festivals, :slug, unique: true
  end
end
