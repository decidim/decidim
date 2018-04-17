# frozen_string_literal: true

class RenameFeaturesToComponents < ActiveRecord::Migration[5.1]
  def change
    rename_table :decidim_features, :decidim_components
    rename_column :decidim_action_logs, :decidim_feature_id, :decidim_component_id
    rename_index :decidim_action_logs, "index_action_logs_on_feature_id", "index_action_logs_on_component_id"

    if index_name_exists?(:decidim_components, "index_decidim_features_on_decidim_participatory_space")
      rename_index :decidim_components, "index_decidim_features_on_decidim_participatory_space", "index_decidim_components_on_decidim_participatory_space"
    end
  end
end
