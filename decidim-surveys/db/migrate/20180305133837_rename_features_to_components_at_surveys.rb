# frozen_string_literal: true

class RenameFeaturesToComponentsAtSurveys < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_surveys_surveys, :decidim_feature_id, :decidim_component_id

    if index_name_exists?(:decidim_surveys_surveys, "index_decidim_surveys_surveys_on_decidim_feature_id")
      rename_index :decidim_surveys_surveys, "index_decidim_surveys_surveys_on_decidim_feature_id", "index_decidim_surveys_surveys_on_decidim_component_id"
    end
  end
end
