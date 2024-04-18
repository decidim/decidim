# frozen_string_literal: true

class AddAttachmentsCounterCacheToParticipatoryProcesses < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_participatory_processes, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::ParticipatoryProcess.reset_column_information
        Decidim::ParticipatoryProcess.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
