# This migration comes from decidim_admin (originally 20170714083651)
# frozen_string_literal: true

class RenameParticipatoryProcessUserRolesTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :decidim_admin_participatory_process_user_roles, :decidim_participatory_process_user_roles
  end
end
