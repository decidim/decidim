# This migration comes from decidim_assemblies (originally 20180109105917)
# frozen_string_literal: true

class AddAssemblyUserRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_assembly_user_roles do |t|
      t.integer :decidim_user_id
      t.integer :decidim_assembly_id
      t.string :role
      t.timestamps
    end

    add_index :decidim_assembly_user_roles,
              [:decidim_assembly_id, :decidim_user_id, :role],
              unique: true,
              name: "index_unique_user_and_assembly_role"
  end
end
