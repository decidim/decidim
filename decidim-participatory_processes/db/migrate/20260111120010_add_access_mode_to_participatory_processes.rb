# frozen_string_literal: true

class AddAccessModeToParticipatoryProcesses < ActiveRecord::Migration[6.1]
  def up
    add_column :decidim_participatory_processes, :access_mode, :integer, null: false, default: 0
  end

  def down
    remove_column :decidim_participatory_processes, :access_mode
  end
end
