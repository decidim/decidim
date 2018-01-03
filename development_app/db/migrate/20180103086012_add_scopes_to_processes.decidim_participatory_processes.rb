# This migration comes from decidim_participatory_processes (originally 20170221094835)
# frozen_string_literal: true

class AddScopesToProcesses < ActiveRecord::Migration[5.0]
  def change
    rename_column :decidim_participatory_processes, :scope, :meta_scope
    add_column :decidim_participatory_processes, :decidim_scope_id, :integer
  end
end
