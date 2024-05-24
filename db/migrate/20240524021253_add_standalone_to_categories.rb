class AddStandaloneToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :standalone, :boolean, default: false, null: false
  end
end
