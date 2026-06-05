# frozen_string_literal: true

class AddIndexOnDecidimMembers < ActiveRecord::Migration[8.1]
  class Member < ApplicationRecord
    self.table_name = :decidim_members
  end

  def up
    Member.where(decidim_user_id: nil).delete_all

    Member.find_each do |member|
      member.delete if Member.where(
        decidim_user_id: member.decidim_user_id,
        participatory_space_type: member.participatory_space_type,
        participatory_space_id: member.participatory_space_id
      ).count > 1
    end

    add_index(:decidim_members, [:decidim_user_id, :participatory_space_type, :participatory_space_id], name: "unique_space_members", unique: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
