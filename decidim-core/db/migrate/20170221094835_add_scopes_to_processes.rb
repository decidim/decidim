class AddScopesToProcesses < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_participatory_processes, :scope_ids, :integer, array: true, default: []
  end
end
