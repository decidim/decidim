# frozen_string_literal: true

class CreateDecidimTaxonomies < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_taxonomies do |t|
      t.jsonb :name, null: false, default: {}
      t.references :decidim_organization, null: false, index: true
      t.references :parent, index: true
      t.integer :weight
      t.integer :children_count, null: false, default: 0
      t.integer :taxonomizations_count, null: false, default: 0
      t.timestamps
    end

    create_table :decidim_taxonomizations do |t|
      t.references :taxonomy, null: false, index: true
      t.references :taxonomizable, null: false, polymorphic: true, index: { name: "index_taxonomizations_on_taxonomizable" }
      t.timestamps
    end

    add_index :decidim_taxonomizations, [:taxonomy_id, :taxonomizable_id, :taxonomizable_type], name: "index_taxonomizations_on_id_tid_and_ttype", unique: true
  end
end
