class CreateDecidimTaxonomyFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_taxonomy_filters do |t|
      t.integer :taxonomy_id, null: false
      t.integer :filterable_id, null: false
      t.string :filterable_type, null: false
      t.timestamps
    end

    add_index :decidim_taxonomy_filters, :taxonomy_id
    add_index :decidim_taxonomy_filters, [:filterable_id, :filterable_type], name: "index_taxonomy_filters_on_fid_and_ftype"

    add_column :decidim_taxonomies, :filters_count, :integer, null: false, default: 0
  end
end
