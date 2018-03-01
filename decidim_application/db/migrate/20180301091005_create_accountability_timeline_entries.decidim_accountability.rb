# This migration comes from decidim_accountability (originally 20170620154712)
# frozen_string_literal: true

class CreateAccountabilityTimelineEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_accountability_timeline_entries do |t|
      t.date :entry_date, index: true
      t.jsonb :description
      t.references :decidim_accountability_result, index: { name: :index_decidim_accountability_timeline_entries_on_results_id }

      t.timestamps
    end
  end
end
