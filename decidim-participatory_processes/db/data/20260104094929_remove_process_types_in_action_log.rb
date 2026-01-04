# frozen_string_literal: true

class RemoveProcessTypesInActionLog < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  def up
    deleted_count = ActionLog.where(resource_type: "Decidim::ParticipatoryProcessType").count

    ActionLog.where(resource_type: "Decidim::ParticipatoryProcessType").delete_all

    Rails.logger.info "Deleted #{deleted_count} ActionLog records with name Decidim::ParticipatoryProcessType"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
