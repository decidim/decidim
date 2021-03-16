# frozen_string_literal: true

class AddFollowableCounterCacheToParticipatoryProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Decidim::ParticipatoryProcess.reset_column_information
        Decidim::ParticipatoryProcess.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
