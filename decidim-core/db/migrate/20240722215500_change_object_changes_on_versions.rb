# frozen_string_literal: true

class ChangeObjectChangesOnVersions < ActiveRecord::Migration[6.1]
  def up
    rename_column :versions, :object_changes, :old_object_changes
    add_column :versions, :object_changes, :jsonb # or :json

    PaperTrail::Version.where.not(old_object_changes: nil).find_each do |version|
      # we set a time interval to ensure that deployment has succeeded
      Decidim::Migrate::PapertrailJob.set(wait: 10.minutes).perform_later(version.id)
    rescue NameError
      Rails.logger.info "Skipping History of #{version.item_type} with id #{version.item_id}"
    end

    PaperTrail::Version.reset_column_information
    remove_column :versions, :old_object_changes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
