class AddSlugToCritic < ActiveRecord::Migration[7.1]
  def change
    add_column :critics, :slug, :string
    add_index :critics, :slug, unique: true
  end
end
