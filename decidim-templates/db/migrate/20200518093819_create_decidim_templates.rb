# frozen_string_literal: true

class CreateDecidimTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_templates do |t|
      t.integer :decidim_organization_id, null: false, index: { name: "index_decidim_questionnaire_templates_organization" }
      t.references :author, null: false, index: { name: "decidim_templates_author" }
      t.references :model, null: false, polymorphic: true, index: { name: "decidim_templates_model" }
      t.timestamps
    end
  end
end
