# This migration comes from decidim_participatory_processes (originally 20161019072016)
# frozen_string_literal: true

class AddActiveFlagToStep < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_participatory_process_steps, :active, :boolean, default: false

    add_index :decidim_participatory_process_steps,
              [:decidim_participatory_process_id, :active],
              unique: true,
              where: "active = 't'",
              name: "unique_index_to_avoid_duplicate_active_steps"
  end
end
