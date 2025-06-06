# frozen_string_literal: true

class RenameTimelineTableToMilestone < ActiveRecord::Migration[7.2]
  def up
    return unless table_exists?(:decidim_accountability_timeline_entries)

    execute "ALTER TABLE decidim_accountability_timeline_entries RENAME TO decidim_accountability_milestone_entries"

    if ActiveRecord::Base.connection.index_exists?(:decidim_accountability_milestone_entries, :decidim_accountability_result_id,
                                                   name: "index_decidim_accountability_timeline_entries_on_results_id")
      execute "ALTER INDEX index_decidim_accountability_timeline_entries_on_results_id RENAME TO index_decidim_accountability_milestone_entries_on_results_id"
    end
  end

  def down
    if table_exists?(:decidim_accountability_milestone_entries)
      if ActiveRecord::Base.connection.index_exists?(:decidim_accountability_milestone_entries, :decidim_accountability_result_id,
                                                     name: "index_decidim_accountability_milestone_entries_on_results_id")
        execute "ALTER INDEX index_decidim_accountability_milestone_entries_on_results_id RENAME TO index_decidim_accountability_timeline_entries_on_results_id"
      end
      execute "ALTER TABLE decidim_accountability_milestone_entries RENAME TO decidim_accountability_timeline_entries"
    end
  end
end
