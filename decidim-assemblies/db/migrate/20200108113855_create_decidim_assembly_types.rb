# frozen_string_literal: true

class CreateDecidimAssemblyTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_assemblies_types do |t|
      t.jsonb :title, null: false

      t.integer :decidim_organization_id,
                foreign_key: true,
                index: {
                  name: "index_decidim_assemblies_types_on_decidim_organization_id"
                }

      t.timestamps
    end

    add_reference :decidim_assemblies, :decidim_assemblies_type, index: true, foreign_key: true
  end
end
