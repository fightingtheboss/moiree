# frozen_string_literal: true

class CreateSocialPosts < ActiveRecord::Migration[8.1]
  def change
    create_table(:social_posts) do |t|
      t.references(:edition, null: false, foreign_key: true)
      t.string(:content_type, null: false)
      t.string(:platform, null: false)
      t.string(:status, null: false, default: "pending")
      t.string(:external_id)
      t.text(:error)
      t.datetime(:posted_at)
      t.text(:caption)

      t.timestamps
    end
  end
end
