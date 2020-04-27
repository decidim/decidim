# frozen_string_literal: true

class CreateDecidimAssembliesSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_assemblies_settings do |t|
      t.boolean :organization_chart_enabled
      t.integer :decidim_organization_id, 
                foreign_key: true

      t.timestamps
    end
  end
end
