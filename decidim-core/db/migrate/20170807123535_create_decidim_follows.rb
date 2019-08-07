# frozen_string_literal: true

class CreateDecidimFollows < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_follows do |t|
      t.references :decidim_user, null: false
      t.references :decidim_followable, polymorphic: true, index: false
      t.timestamps
    end

    add_index :decidim_follows,
              [:decidim_user_id, :decidim_followable_id, :decidim_followable_type],
              unique: true,
              name: "index_uniq_on_follows_user_and_followable"
    add_index :decidim_follows,
              [:decidim_followable_id, :decidim_followable_type],
              unique: true,
              name: "index_uniq_on_followable"
  end
end
