# frozen_string_literal: true

class RenameTimelineTableToMilestone < ActiveRecord::Migration[7.2]
  def change
    rename_table :decidim_accountability_timeline_entries, :decidim_accountability_milestones

    rename_index :decidim_accountability_milestones,
                 "index_decidim_accountability_timeline_entries_on_results_id",
                 "index_decidim_accountability_milestones_on_results_id"
  end
end
