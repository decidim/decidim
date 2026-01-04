# frozen_string_literal: true

class RemoveProcessTypesInVersions < ActiveRecord::Migration[7.2]
  def up
    deleted_count = PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessType").count

    PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessType").delete_all

    Rails.logger.info "Deleted #{deleted_count} PaperTrail records with name Decidim::ParticipatoryProcessType"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
