# frozen_string_literal: true

class RenameParticipatoryProcessStepReferences < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = "decidim_action_logs"
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  class Component < ApplicationRecord
    self.table_name = "decidim_components"
  end

  OLD_TYPE = "Decidim::ParticipatoryProcessStep"
  NEW_TYPE = "Decidim::ParticipatoryProcessPhase"

  SETTINGS_KEY_RENAMES = {
    "steps" => "phases",
    "default_step" => "default_phase"
  }.freeze

  def up
    rename_references(OLD_TYPE, NEW_TYPE)
    rename_component_settings(SETTINGS_KEY_RENAMES)
  end

  def down
    rename_references(NEW_TYPE, OLD_TYPE)
    rename_component_settings(SETTINGS_KEY_RENAMES.invert)
  end

  private

  def rename_component_settings(key_renames)
    Component.find_each do |component|
      settings = component.settings
      next if settings.blank?

      renamed = settings.dup
      key_renames.each do |old_key, new_key|
        renamed[new_key] = renamed.delete(old_key) if renamed.has_key?(old_key)
      end
      next if renamed == settings

      component.update_column(:settings, renamed) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def rename_references(from_type, to_type)
    action_logs = ActionLog.where(resource_type: from_type).update_all(resource_type: to_type) # rubocop:disable Rails/SkipsModelValidations
    versions = Version.where(item_type: from_type).update_all(item_type: to_type) # rubocop:disable Rails/SkipsModelValidations

    Rails.logger.info "Renamed #{from_type} to #{to_type} in #{action_logs} action logs and #{versions} versions"
  end
end
