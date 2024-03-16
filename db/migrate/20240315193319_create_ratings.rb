class CreateRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :ratings do |t|
      t.references :critic, null: false, foreign_key: true
      t.references :selection, null: false, foreign_key: true
      t.decimal :score, precision: 2, scale: 1

      t.timestamps
    end
  end
end
