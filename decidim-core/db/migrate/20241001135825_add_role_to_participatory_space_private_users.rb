# frozen_string_literal: true

class AddRoleToParticipatorySpacePrivateUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_participatory_space_private_users, :role, :jsonb
  end
end
