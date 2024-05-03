class AddPositionedToCategories < ActiveRecord::Migration[7.1]
  def up
    add_column :categories, :position, :integer

    Edition.all.each do |edition|
      edition.categories.each_with_index do |category, index|
        category.update!(position: index + 1)
      end
    end

    change_column_null :categories, :position, false
    add_index :categories, [:edition_id, :position], unique: true
  end

  def down
    remove_index :categories, [:edition_id, :position]
    remove_column :categories, :position
  end
end
