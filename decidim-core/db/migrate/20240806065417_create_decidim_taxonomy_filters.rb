# frozen_string_literal: true

class CreateDecidimTaxonomyFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_taxonomy_filters do |t|
      t.references :root_taxonomy, null: false, foreign_key: { to_table: :decidim_taxonomies }
      t.integer :filter_items_count, null: false, default: 0
      t.string :space_manifest, null: false
      t.timestamps
    end

    create_table :decidim_taxonomy_filter_items do |t|
      t.references :taxonomy_filter, null: false, index: true
      t.references :taxonomy_item, null: false, foreign_key: { to_table: :decidim_taxonomies }
      t.timestamps
    end

    add_index :decidim_taxonomy_filter_items, [:taxonomy_filter_id, :taxonomy_item_id], name: "index_taxonomy_filter_items_on_filter_id_and_item_id", unique: true

    add_column :decidim_taxonomies, :filters_count, :integer, null: false, default: 0
    add_column :decidim_taxonomies, :filter_items_count, :integer, null: false, default: 0
  end
end
