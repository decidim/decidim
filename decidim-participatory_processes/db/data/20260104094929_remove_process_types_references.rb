# frozen_string_literal: true

class RemoveProcessTypesReferences < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = "decidim_action_logs"
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  class Notification < ApplicationRecord
    self.table_name = "decidim_notifications"
  end

  def up
    ActionLog.where(resource_type: "Decidim::ParticipatoryProcessType").delete_all
    Version.where(item_type: "Decidim::ParticipatoryProcessType").delete_all
    Notification.where(decidim_resource_type: "Decidim::ParticipatoryProcessType").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
