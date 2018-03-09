# frozen_string_literal: true

class RenameFeaturesToComponentsAtProposals < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_proposals_proposals, :decidim_feature_id, :decidim_component_id

    if index_name_exists?(:decidim_proposals_proposals, "index_decidim_proposals_proposals_on_decidim_feature_id")
      rename_index :decidim_proposals_proposals, "index_decidim_proposals_proposals_on_decidim_feature_id", "index_decidim_proposals_proposals_on_decidim_component_id"
    end
  end
end
