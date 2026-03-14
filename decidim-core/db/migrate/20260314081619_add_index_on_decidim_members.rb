# frozen_string_literal: true

class AddIndexOnDecidimMembers < ActiveRecord::Migration[8.1]
  def up
    execute "DELETE FROM decidim_members WHERE decidim_user_id IS NULL;"
    execute <<~SQL.squish
      DELETE FROM decidim_members m1
      USING decidim_members m2
      WHERE m1.id < m2.id
        AND m1.decidim_user_id = m2.decidim_user_id
        AND m1.participatory_space_type = m2.participatory_space_type
        AND m1.participatory_space_id = m2.participatory_space_id;
    SQL

    add_index(:decidim_members, [:decidim_user_id, :participatory_space_type, :participatory_space_id], name: "unique_space_members", unique: true)
  end

  def down
    remove_index(:decidim_members, name: "unique_space_members")
  end
end
