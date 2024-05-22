class AddAverageRatingToSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :selections, :average_rating, :decimal, precision: 2, scale: 1
  end
end
