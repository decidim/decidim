# This migration comes from decidim_participatory_processes (originally 20170809084005)
# frozen_string_literal: true

class AddScopesEnabledToParticipatoryProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_participatory_processes, :scopes_enabled, :boolean, null: false, default: true
  end
end
