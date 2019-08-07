# frozen_string_literal: true

class FixSortitionsProposalFeature < ActiveRecord::Migration[5.1]
  def up
    rename_column :decidim_sortitions_sortitions, :decidim_proposals_feature_id, :decidim_proposals_component_id
  end

  def down
    rename_column :decidim_sortitions_sortitions, :decidim_proposals_component_id, :decidim_proposals_feature_id
  end
end
