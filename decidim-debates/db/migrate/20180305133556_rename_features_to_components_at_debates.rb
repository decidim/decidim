# frozen_string_literal: true

class RenameFeaturesToComponentsAtDebates < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_debates_debates, :decidim_feature_id, :decidim_component_id

    if index_name_exists?(:decidim_debates_debates, "index_decidim_debates_debates_on_decidim_feature_id")
      rename_index :decidim_debates_debates, "index_decidim_debates_debates_on_decidim_feature_id", "index_decidim_debates_debates_on_decidim_component_id"
    end
  end
end
