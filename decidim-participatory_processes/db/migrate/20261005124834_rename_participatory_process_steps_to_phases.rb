# frozen_string_literal: true

class RenameParticipatoryProcessStepsToPhases < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = "decidim_action_logs"
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

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

    reversible do |dir|
      dir.up do
        ActionLog.where(resource_type: "Decidim::ParticipatoryProcessStep").update_all(resource_type: "Decidim::ParticipatoryProcessPhase") # rubocop:disable Rails/SkipsModelValidations
        Version.where(item_type: "Decidim::ParticipatoryProcessStep").update_all(item_type: "Decidim::ParticipatoryProcessPhase") # rubocop:disable Rails/SkipsModelValidations
      end

      dir.down do
        ActionLog.where(resource_type: "Decidim::ParticipatoryProcessPhase").update_all(resource_type: "Decidim::ParticipatoryProcessStep") # rubocop:disable Rails/SkipsModelValidations
        Version.where(item_type: "Decidim::ParticipatoryProcessPhase").update_all(item_type: "Decidim::ParticipatoryProcessStep") # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
