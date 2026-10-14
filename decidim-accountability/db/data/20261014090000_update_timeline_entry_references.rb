# frozen_string_literal: true

class UpdateTimelineEntryReferences < ActiveRecord::Migration[7.2]
  LEGACY_TYPE = "Decidim::Accountability::TimelineEntry"
  MILESTONE_TYPE = "Decidim::Accountability::Milestone"

  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  def up
    ActionLog.where(resource_type: LEGACY_TYPE).update_all(resource_type: MILESTONE_TYPE)
    Version.where(item_type: LEGACY_TYPE).update_all(item_type: MILESTONE_TYPE)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
