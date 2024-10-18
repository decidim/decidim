# frozen_string_literal: true

class AddDeletedAtToDecidimMeetingsMeetings < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_meetings_meetings, :deleted_at, :datetime
    add_index :decidim_meetings_meetings, :deleted_at
  end
end
