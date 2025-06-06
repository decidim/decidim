# frozen_string_literal: true

class RenameTimelineTableToMilestone < ActiveRecord::Migration[7.2]
  def change
    rename_table :decidim_accountability_timeline_entries, :decidim_accountability_milestone_entries
  end
end
