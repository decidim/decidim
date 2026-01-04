# frozen_string_literal: true

class RemoveAssembliesTypesInActionLog < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  def up
    deleted_count = ActionLog.where(resource_type: "Decidim::AssembliesType").count

    ActionLog.where(resource_type: "Decidim::AssembliesType").delete_all

    Rails.logger.info "Deleted #{deleted_count} ActionLog records with name Decidim::AssembliesType"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
