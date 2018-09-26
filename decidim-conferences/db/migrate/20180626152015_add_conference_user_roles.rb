# frozen_string_literal: true

class AddConferenceUserRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_conference_user_roles do |t|
      t.integer :decidim_user_id
      t.integer :decidim_conference_id
      t.string :role
      t.timestamps
    end

    add_index :decidim_conference_user_roles,
              [:decidim_conference_id, :decidim_user_id, :role],
              unique: true,
              name: "index_unique_user_and_conference_role"
  end
end
