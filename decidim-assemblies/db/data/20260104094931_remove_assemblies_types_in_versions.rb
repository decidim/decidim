# frozen_string_literal: true

class RemoveAssembliesTypesInVersions < ActiveRecord::Migration[7.2]
  def up
    deleted_count = PaperTrail::Version.where(item_type: "Decidim::AssembliesType").count

    PaperTrail::Version.where(item_type: "Decidim::AssembliesType").delete_all

    Rails.logger.info "Deleted #{deleted_count} PaperTrail records with name Decidim::AssembliesType"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
