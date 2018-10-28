# frozen_string_literal: true

class ChangeUserGroupsVerifiedToTimestamp < ActiveRecord::Migration[5.0]
  def change
    ActiveRecord::Base.transaction do
      add_column :decidim_user_groups, :verified_at, :datetime
      execute("UPDATE decidim_user_groups SET verified_at = '#{Time.current.to_s(:db)}' WHERE verified = 't'")
      remove_column :decidim_user_groups, :verified
    end
  end
end
