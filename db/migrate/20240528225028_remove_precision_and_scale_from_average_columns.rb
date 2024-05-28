class RemovePrecisionAndScaleFromAverageColumns < ActiveRecord::Migration[7.1]
  def change
    change_column :selections, :average_rating, :decimal
    change_column :films, :overall_average_rating, :decimal
  end
end
