# frozen_string_literal: true

class RenamePrivatableToToParticipatorySpaceInMembers < ActiveRecord::Migration[7.2]
  def change
    rename_column :decidim_members, :privatable_to_id, :participatory_space_id
    rename_column :decidim_members, :privatable_to_type, :participatory_space_type

    rename_index :decidim_members, "space_privatable_to_privatable_id", "index_decidim_members_on_participatory_space"
  end
end
