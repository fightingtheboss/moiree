# frozen_string_literal: true

class CreateYearInReviews < ActiveRecord::Migration[8.0]
  def change
    create_table(:year_in_reviews) do |t|
      t.integer :year, null: false
      t.integer :editions_count, default: 0, null: false
      t.integer :critics_count, default: 0, null: false
      t.integer :films_count, default: 0, null: false
      t.integer :ratings_count, default: 0, null: false
      t.integer :five_star_ratings_count, default: 0, null: false
      t.integer :zero_star_ratings_count, default: 0, null: false
      t.references :bombe_moiree_selection, foreign_key: { to_table: :selections }
      t.references :most_divisive_selection, foreign_key: { to_table: :selections }
      t.datetime :generated_at
      t.timestamps
    end

    add_index(:year_in_reviews, :year, unique: true)

    create_table(:year_in_review_top_selections) do |t|
      t.references :year_in_review, null: false, foreign_key: true
      t.references :selection, null: false, foreign_key: true
      t.integer :position, null: false
      t.timestamps
    end

    add_index(
      :year_in_review_top_selections,
      [:year_in_review_id, :selection_id],
      unique: true,
      name: "idx_yir_top_selections_on_yir_and_selection",
    )

    add_index(
      :year_in_review_top_selections,
      [:year_in_review_id, :position],
      unique: true,
      name: "idx_yir_top_selections_on_yir_and_position",
    )
  end
end
