class AddImpressionToRating < ActiveRecord::Migration[8.0]
  def change
    add_column :ratings, :impression, :text
  end
end
