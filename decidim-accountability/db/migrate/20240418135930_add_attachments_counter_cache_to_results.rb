# frozen_string_literal: true

class AddAttachmentsCounterCacheToResults < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_accountability_results, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Accountability::Result.reset_column_information
        Decidim::Accountability::Result.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
