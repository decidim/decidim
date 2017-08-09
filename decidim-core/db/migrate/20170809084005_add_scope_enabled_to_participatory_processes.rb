# frozen_string_literal: true

class AddScopeEnabledToParticipatoryProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_participatory_processes, :scope_enabled, :boolean, null: false, default: true
  end
end
