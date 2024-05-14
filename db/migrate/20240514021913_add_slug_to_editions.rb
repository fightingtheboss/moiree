class AddSlugToEditions < ActiveRecord::Migration[7.1]
  def change
    add_column :editions, :slug, :string
    add_index :editions, [:festival_id, :slug], unique: true
  end
end
