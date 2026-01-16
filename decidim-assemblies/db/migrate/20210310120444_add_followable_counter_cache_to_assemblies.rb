# frozen_string_literal: true

class AddFollowableCounterCacheToAssemblies < ActiveRecord::Migration[5.2]
  class Assembly < ApplicationRecord
    self.table_name = :decidim_assemblies
  end

  def change
    add_column :decidim_assemblies, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Assembly.reset_column_information
        Assembly.unscoped.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
