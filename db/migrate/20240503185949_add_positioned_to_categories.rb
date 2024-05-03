class AddPositionedToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :position, :integer
    add_index :categories, [:edition_id, :position], unique: true
  end
end
