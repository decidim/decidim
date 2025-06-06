# frozen_string_literal: true

class RenameTimelineToMilestoneEntries < ActiveRecord::Migration[7.0]
  def change
    def up # rubocop:disable Lint/NestedMethodDefinition
      rename_table :decidim_accountability_timeline_entries, :decidim_accountability_milestone_entries

      rename_index :decidim_accountability_milestone_entries,
                   :index_decidim_accountability_timeline_entries_on_results_id,
                   :index_decidim_accountability_milestone_entries_on_results_id

      rename_index :decidim_accountability_milestone_entries,
                   :index_decidim_accountability_timeline_entries_on_entry_date,
                   :index_decidim_accountability_milestone_entries_on_entry_date
    end

    def down # rubocop:disable Lint/NestedMethodDefinition
      rename_index :decidim_accountability_milestone_entries,
                   :index_decidim_accountability_milestone_entries_on_results_id,
                   :index_decidim_accountability_timeline_entries_on_results_id

      rename_index :decidim_accountability_milestone_entries,
                   :index_decidim_accountability_milestone_entries_on_entry_date,
                   :index_decidim_accountability_timeline_entries_on_entry_date

      rename_table :decidim_accountability_milestone_entries, :decidim_accountability_timeline_entries
    end
  end
end
