# frozen_string_literal: true

class AddPrivateAndUserIdsToAssemblies < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_assemblies, :private_assembly, :boolean, default: false

    create_table :decidim_assembly_users do |t|
      t.references :decidim_assembly, index: { name: "index_decidim_assemblies_on_decidim_assembly_id" }
      t.references :decidim_user, index: { name: "index_decidim_assemblies_users_on_decidim_user_id" }
    end
  end
end
