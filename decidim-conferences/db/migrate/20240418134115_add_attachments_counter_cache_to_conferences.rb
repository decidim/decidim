# frozen_string_literal: true

class AddAttachmentsCounterCacheToConferences < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_conferences, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Conference.reset_column_information
        Decidim::Conference.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
