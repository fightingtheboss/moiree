class AddCategoryIdToSelections < ActiveRecord::Migration[7.1]
  def change
    add_reference :selections, :category, foreign_key: true
  end
end
