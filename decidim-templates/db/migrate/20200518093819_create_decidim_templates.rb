# frozen_string_literal: true

class CreateDecidimTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_templates_templates do |t|
      t.integer :decidim_organization_id, null: false, index: { name: "index_decidim_templates_organization" }
      t.references :templatable, null: false, polymorphic: true, index: { name: "index_decidim_templates_templatable" }
      t.jsonb :name
      t.timestamps
    end
  end
end
