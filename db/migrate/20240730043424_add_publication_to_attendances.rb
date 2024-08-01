class AddPublicationToAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances, :publication, :string
  end
end
