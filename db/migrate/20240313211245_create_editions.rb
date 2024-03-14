class CreateEditions < ActiveRecord::Migration[7.1]
  def change
    create_table :editions do |t|
      t.references :festival, null: false, foreign_key: true
      t.integer :year
      t.string :code
      t.string :url
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
