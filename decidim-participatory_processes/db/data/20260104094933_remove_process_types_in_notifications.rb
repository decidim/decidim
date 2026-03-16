# frozen_string_literal: true

class RemoveProcessTypesInNotifications < ActiveRecord::Migration[7.2]
  def up
    deleted_count = Decidim::Notification.where(decidim_resource_type: "Decidim::ParticipatoryProcessType").count

    Decidim::Notification.where(decidim_resource_type: "Decidim::ParticipatoryProcessType").delete_all

    Rails.logger.info "Deleted #{deleted_count} notifications records with name Decidim::ParticipatoryProcessType"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
