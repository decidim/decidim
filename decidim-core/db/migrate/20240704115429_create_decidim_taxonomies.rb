# frozen_string_literal: true

class CreateDecidimTaxonomies < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_taxonomies do |t|
      t.jsonb :name, null: false, default: {}
      t.integer :decidim_organization_id, null: false
      t.integer :parent_id
      t.integer :weight
      t.integer :children_count, :integer, null: false, default: 0
      t.integer :taxonomizations_count, :integer, null: false, default: 0
      t.integer :filters_count, :integer, null: false, default: 0
      t.timestamps
    end

    add_index :decidim_taxonomies, :decidim_organization_id
    add_index :decidim_taxonomies, :parent_id

    create_table :decidim_taxonomy_filters do |t|
      t.integer :taxonomy_id, null: false
      t.integer :filterable_id, null: false
      t.string :filterable_type, null: false
      t.timestamps
    end

    add_index :decidim_taxonomy_filters, :taxonomy_id
    add_index :decidim_taxonomy_filters, [:filterable_id, :filterable_type], name: "index_taxonomy_filters_on_fid_and_ftype"

    create_table :decidim_taxonomizations do |t|
      t.integer :taxonomy_id, null: false
      t.integer :taxonomizable_id, null: false
      t.string :taxonomizable_type, null: false
      t.timestamps
    end

    add_index :decidim_taxonomizations, :taxonomy_id
    add_index :decidim_taxonomizations, [:taxonomizable_id, :taxonomizable_type], name: "index_taxonomizations_on_tid_and_ttype"
  end
end
