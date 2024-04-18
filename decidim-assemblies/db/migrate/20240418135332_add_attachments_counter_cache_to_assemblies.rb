# frozen_string_literal: true

class AddAttachmentsCounterCacheToAssemblies < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_assemblies, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Assembly.reset_column_information
        Decidim::Assembly.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
