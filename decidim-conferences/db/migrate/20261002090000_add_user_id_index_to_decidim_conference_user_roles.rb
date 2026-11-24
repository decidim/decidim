# frozen_string_literal: true

class AddUserIdIndexToDecidimConferenceUserRoles < ActiveRecord::Migration[7.2]
  def change
    add_index :decidim_conference_user_roles, :decidim_user_id, name: "index_decidim_conference_user_role_on_decidim_user_id"
  end
end
