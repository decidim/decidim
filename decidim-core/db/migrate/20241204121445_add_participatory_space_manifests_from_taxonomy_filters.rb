# frozen_string_literal: true

class AddParticipatorySpaceManifestsFromTaxonomyFilters < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_taxonomy_filters, :space_manifest
    remove_column :decidim_taxonomy_filters, :space_filter
    add_column :decidim_taxonomy_filters, :participatory_space_manifests, :string, array: true, default: [], null: false
  end
end
