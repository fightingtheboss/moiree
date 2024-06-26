class DropCategorizations < ActiveRecord::Migration[7.1]
  def change
    drop_table :categorizations do |t|
      t.references :category, null: false, foreign_key: true
      t.references :film, null: false, foreign_key: true

      t.timestamps
    end
  end
end
