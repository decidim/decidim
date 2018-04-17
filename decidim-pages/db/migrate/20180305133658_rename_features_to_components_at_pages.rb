# frozen_string_literal: true

class RenameFeaturesToComponentsAtPages < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_pages_pages, :decidim_feature_id, :decidim_component_id

    if index_name_exists?(:decidim_pages_pages, "index_decidim_pages_pages_on_decidim_feature_id")
      rename_index :decidim_pages_pages, "index_decidim_pages_pages_on_decidim_feature_id", "index_decidim_pages_pages_on_decidim_component_id"
    end
  end
end
