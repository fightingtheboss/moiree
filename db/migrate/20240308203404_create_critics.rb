class CreateCritics < ActiveRecord::Migration[7.1]
  def change
    create_table :critics do |t|
      t.string :first_name
      t.string :last_name
      t.string :publication
      t.string :country

      t.timestamps
    end
  end
end
