# frozen_string_literal: true

class AddFollowableCounterCacheToMeetings < ActiveRecord::Migration[5.2]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
    include Decidim::HasComponent
    include Decidim::Followable
  end

  def change
    add_column :decidim_meetings_meetings, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Meeting.reset_column_information
        Meeting.unscoped.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
