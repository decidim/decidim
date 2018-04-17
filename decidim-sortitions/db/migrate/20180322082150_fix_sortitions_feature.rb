# frozen_string_literal: true

class FixSortitionsFeature < ActiveRecord::Migration[5.1]
  def up
    rename_column :decidim_sortitions_sortitions, :decidim_feature_id, :decidim_component_id
  end

  def down
    rename_column :decidim_sortitions_sortitions, :decidim_component_id, :decidim_feature_id
  end
end
