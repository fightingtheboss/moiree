class CreateAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :attendances do |t|
      t.references :critic, null: false, foreign_key: true
      t.references :edition, null: false, foreign_key: true

      t.timestamps
    end
  end
end
