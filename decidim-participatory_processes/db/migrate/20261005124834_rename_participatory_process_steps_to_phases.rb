# frozen_string_literal: true

class RenameParticipatoryProcessStepsToPhases < ActiveRecord::Migration[7.2]
  def change
    rename_table :decidim_participatory_process_steps, :decidim_participatory_process_phases

    rename_index :decidim_participatory_process_phases,
                 "index_decidim_processes_steps__on_decidim_process_id",
                 "index_decidim_processes_phases__on_decidim_process_id"
    rename_index :decidim_participatory_process_phases,
                 "index_order_by_position_for_steps",
                 "index_order_by_position_for_phases"
    rename_index :decidim_participatory_process_phases,
                 "unique_index_to_avoid_duplicate_active_steps",
                 "unique_index_to_avoid_duplicate_active_phases"
  end
end
