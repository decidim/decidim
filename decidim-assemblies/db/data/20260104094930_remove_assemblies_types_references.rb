# frozen_string_literal: true

class RemoveAssembliesTypesReferences < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  class Notification < ApplicationRecord
    self.table_name = "decidim_notifications"
  end

  def up
    ActionLog.where(resource_type: "Decidim::AssembliesType").delete_all
    Version.where(item_type: "Decidim::AssembliesType").delete_all
    Notification.where(decidim_resource_type: "Decidim::AssembliesType").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
