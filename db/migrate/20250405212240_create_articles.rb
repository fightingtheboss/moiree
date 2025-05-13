class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.references :critic, null: false, foreign_key: true
      t.datetime :published_at

      t.timestamps
    end
  end
end
