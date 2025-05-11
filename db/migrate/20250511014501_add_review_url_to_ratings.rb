class AddReviewUrlToRatings < ActiveRecord::Migration[8.0]
  def change
    add_column :ratings, :review_url, :string
  end
end
