# frozen_string_literal: true

class AddFollowableCounterCacheToMeetings < ActiveRecord::Migration[5.2]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings

    has_many :follows,
             as: :followable,
             foreign_key: "decidim_followable_id",
             foreign_type: "decidim_followable_type",
             class_name: "Decidim::Follow",
             counter_cache: :follows_count
  end

  def change
    add_column :decidim_meetings_meetings, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Meeting.reset_column_information
        Meeting.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
