# frozen_string_literal: true

class CreatePodcasts < ActiveRecord::Migration[8.0]
  def change
    create_table(:podcasts) do |t|
      t.string(:title, null: false)
      t.text(:description)
      t.references(:user, null: false, foreign_key: true)
      t.string(:url)
      t.string(:slug, null: false)
      t.boolean(:platform, default: false)

      t.timestamps
    end
    add_index(:podcasts, :slug, unique: true)
  end
end
