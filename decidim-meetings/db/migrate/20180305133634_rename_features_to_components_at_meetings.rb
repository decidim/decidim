# frozen_string_literal: true

class RenameFeaturesToComponentsAtMeetings < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_meetings_meetings, :decidim_feature_id, :decidim_component_id

    if index_name_exists?(:decidim_meetings_meetings, "index_decidim_meetings_meetings_on_decidim_feature_id")
      rename_index :decidim_meetings_meetings, "index_decidim_meetings_meetings_on_decidim_feature_id", "index_decidim_meetings_meetings_on_decidim_component_id"
    end
  end
end
