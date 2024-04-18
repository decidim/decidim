# frozen_string_literal: true

class AddAttachmentsCounterCacheToInitiatives < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_initiatives, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Initiative.reset_column_information
        Decidim::Initiative.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
