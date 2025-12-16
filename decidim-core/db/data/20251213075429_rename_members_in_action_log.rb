# frozen_string_literal: true

class RenameMembersInActionLog < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  def up
    old_resource_type = "Decidim::ParticipatorySpacePrivateUser"
    new_resource_type = "Decidim::ParticipatorySpace::Member"

    # rubocop:disable Rails/SkipsModelValidations
    updated_count = ActionLog.where(resource_type: old_resource_type).update_all(resource_type: new_resource_type)
    # rubocop:enable Rails/SkipsModelValidations

    Rails.logger.info "Updated #{updated_count} ActionLog records from #{old_resource_type} to #{new_resource_type}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
