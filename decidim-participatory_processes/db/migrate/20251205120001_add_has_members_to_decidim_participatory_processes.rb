# frozen_string_literal: true

class AddHasMembersToDecidimParticipatoryProcesses < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_participatory_processes, :has_members, :boolean, default: false
  end
end
