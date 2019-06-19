# frozen_string_literal: true

class AddUserGroupToMeetingsRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_registrations, :decidim_user_group_id, :bigint
  end
end
