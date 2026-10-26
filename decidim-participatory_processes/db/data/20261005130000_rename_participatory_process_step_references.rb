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

  class Notification < ApplicationRecord
    self.table_name = "decidim_notifications"
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

  EVENT_CLASS_RENAMES = {
    "Decidim::ParticipatoryProcessStepActivatedEvent" => "Decidim::ParticipatoryProcessPhaseActivatedEvent",
    "Decidim::ParticipatoryProcessStepChangedEvent" => "Decidim::ParticipatoryProcessPhaseChangedEvent"
  }.freeze

  EVENT_NAME_RENAMES = {
    "decidim.events.participatory_process.step_activated" => "decidim.events.participatory_process.phase_activated",
    "decidim.events.participatory_process.step_changed" => "decidim.events.participatory_process.phase_changed"
  }.freeze

  def rename_references(from_type, to_type)
    action_logs = ActionLog.where(resource_type: from_type).update_all(resource_type: to_type) # rubocop:disable Rails/SkipsModelValidations
    versions = Version.where(item_type: from_type).update_all(item_type: to_type) # rubocop:disable Rails/SkipsModelValidations
    notifications = Notification.where(decidim_resource_type: from_type).update_all(decidim_resource_type: to_type) # rubocop:disable Rails/SkipsModelValidations

    event_class_renames = from_type == OLD_TYPE ? EVENT_CLASS_RENAMES : EVENT_CLASS_RENAMES.invert
    event_name_renames = from_type == OLD_TYPE ? EVENT_NAME_RENAMES : EVENT_NAME_RENAMES.invert

    event_class_renames.each do |old_value, new_value|
      Notification.where(event_class: old_value).update_all(event_class: new_value) # rubocop:disable Rails/SkipsModelValidations
    end
    event_name_renames.each do |old_value, new_value|
      Notification.where(event_name: old_value).update_all(event_name: new_value) # rubocop:disable Rails/SkipsModelValidations
    end

    Rails.logger.info "Renamed #{from_type} to #{to_type} in #{action_logs} action logs, #{versions} versions and #{notifications} notifications"
  end
end
