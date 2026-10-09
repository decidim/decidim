# frozen_string_literal: true

class RenameParticipatoryProcessPhaseReferences < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = "decidim_action_logs"
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  OLD_TYPE = "Decidim::ParticipatoryProcessPhase"
  NEW_TYPE = "Decidim::ParticipatoryProcessPhase"

  def up
    rename_references(OLD_TYPE, NEW_TYPE)
  end

  def down
    rename_references(NEW_TYPE, OLD_TYPE)
  end

  private

  def rename_references(from_type, to_type)
    action_logs = ActionLog.where(resource_type: from_type).update_all(resource_type: to_type) # rubocop:disable Rails/SkipsModelValidations
    versions = Version.where(item_type: from_type).update_all(item_type: to_type) # rubocop:disable Rails/SkipsModelValidations

    Rails.logger.info "Renamed #{from_type} to #{to_type} in #{action_logs} action logs and #{versions} versions"
  end
end
