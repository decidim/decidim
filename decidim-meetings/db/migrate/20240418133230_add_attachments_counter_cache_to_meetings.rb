# frozen_string_literal: true

class AddAttachmentsCounterCacheToMeetings < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_meetings_meetings, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Meetings::Meeting.reset_column_information
        Decidim::Meetings::Meeting.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
