# frozen_string_literal: true

class CreateAssemblyPrivateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_assembly_private_users do |t|
      t.references :decidim_user, index: { name: "index_decidim_assemblies_users_on_decidim_user_id" }
      t.references :decidim_assembly, index: { name: "index_decidim_assemblies_on_decidim_assembly_id" }

      t.timestamps
    end
  end
end
