class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.references :edition, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
