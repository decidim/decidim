# frozen_string_literal: true

class IndexForeignKeysInDecidimParticipatoryProcesses < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_participatory_processes, :decidim_participatory_process_group_id, name: "idx_process_on_process_group_id"
    add_index :decidim_participatory_processes, :decidim_scope_id, name: "idx_process_on_scope_id"
  end
end
