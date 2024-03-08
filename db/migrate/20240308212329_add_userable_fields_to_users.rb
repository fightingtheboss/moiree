class AddUserableFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :userable, polymorphic: true, null: false
  end
end
