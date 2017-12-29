# This migration comes from decidim_assemblies (originally 20170727190859)
# frozen_string_literal: true

class AddAssemblies < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_assemblies do |t|
      t.string :slug, null: false
      t.string :hashtag

      t.integer :decidim_organization_id,
                foreign_key: true,
                index: { name: "index_decidim_assemblies_on_decidim_organization_id" }

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.jsonb :title, null: false
      t.jsonb :subtitle, null: false
      t.jsonb :short_description, null: false
      t.jsonb :description, null: false
      t.string :hero_image
      t.string :banner_image
      t.boolean :promoted, default: false
      t.datetime :published_at
      t.jsonb :developer_group
      t.jsonb :meta_scope
      t.jsonb :local_area
      t.jsonb :target
      t.jsonb :participatory_scope
      t.jsonb :participatory_structure
      t.boolean :show_statistics, default: false
      t.integer :decidim_scope_id

      t.index [:decidim_organization_id, :slug],
              name: "index_unique_assembly_slug_and_organization",
              unique: true
    end
  end
end
