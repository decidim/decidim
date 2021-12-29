# frozen_string_literal: true

class AddCommentsAvailabilityColumnsToMeetingsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_meetings_meetings, :comments_enabled, :boolean, default: true
    add_column :decidim_meetings_meetings, :comments_start_time, :datetime
    add_column :decidim_meetings_meetings, :comments_end_time, :datetime
    reversible do |dir|
      dir.up do
        execute "UPDATE decidim_meetings_meetings set comments_enabled = true"
      end
    end
  end
end
