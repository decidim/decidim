# frozen_string_literal: true

class AddAdminParticipatoryProcessUserRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_admin_participatory_process_user_roles do |t|
      t.integer :decidim_user_id
      t.integer :decidim_participatory_process_id
      t.string :role
      t.timestamps
    end

    add_index :decidim_admin_participatory_process_user_roles,
              [:decidim_participatory_process_id, :decidim_user_id, :role],
              unique: true,
              name: "index_unique_user_and_process_role"
  end
end
