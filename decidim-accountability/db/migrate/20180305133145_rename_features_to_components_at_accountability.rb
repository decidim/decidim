# frozen_string_literal: true

class RenameFeaturesToComponentsAtAccountability < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_accountability_statuses, :decidim_feature_id, :decidim_component_id
    rename_column :decidim_accountability_results, :decidim_feature_id, :decidim_component_id

    if index_name_exists?(:decidim_accountability_results, "index_decidim_accountability_results_on_decidim_feature_id")
      rename_index :decidim_accountability_results, "index_decidim_accountability_results_on_decidim_feature_id", "index_decidim_accountability_results_on_decidim_component_id"
    end

    if index_name_exists?(:decidim_accountability_statuses, "index_decidim_accountability_statuses_on_decidim_feature_id")
      rename_index :decidim_accountability_statuses, "index_decidim_accountability_statuses_on_decidim_feature_id", "index_decidim_accountability_statuses_on_decidim_component_id"
    end
  end
end
