# frozen_string_literal: true

class RenameParticipatorySpacePrivateUsersToMembers < ActiveRecord::Migration[7.0]
  def change
    rename_table :decidim_participatory_space_private_users, :decidim_members

    rename_index :decidim_members, :index_decidim_spaces_users_on_private_user_id, :index_decidim_members_on_user_id
  end
end
