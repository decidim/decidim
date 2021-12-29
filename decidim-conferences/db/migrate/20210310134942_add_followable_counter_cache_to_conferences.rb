# frozen_string_literal: true

class AddFollowableCounterCacheToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_conferences, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Decidim::Conference.reset_column_information
        Decidim::Conference.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
