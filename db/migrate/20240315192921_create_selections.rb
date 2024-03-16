class CreateSelections < ActiveRecord::Migration[7.1]
  def change
    create_table :selections do |t|
      t.references :edition, null: false, foreign_key: true
      t.references :film, null: false, foreign_key: true

      t.timestamps
    end
  end
end
