# frozen_string_literal: true

class RemoveSpaceManifestFromTaxonomyFilters < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_taxonomy_filters, :space_manifest
    change_column :decidim_taxonomy_filters, :space_filter, :string, null: true
  end
end
