# frozen_string_literal: true

class RemoveUserGroupMeetings < ActiveRecord::Migration[7.0]
  def up
    remove_column :decidim_meetings_meetings, :decidim_user_group_id
    remove_index :decidim_meetings_registrations, :decidim_user_group_id
    remove_column :decidim_meetings_registrations, :decidim_user_group_id
  end

  def down
    add_column :decidim_meetings_meetings, :decidim_user_group_id, :bigint
    add_column :decidim_meetings_registrations, :decidim_user_group_id, :bigint
    add_index :decidim_meetings_registrations, :decidim_user_group_id
  end
end
