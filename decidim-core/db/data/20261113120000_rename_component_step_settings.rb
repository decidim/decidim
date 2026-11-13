# frozen_string_literal: true

class RenameComponentStepSettings < ActiveRecord::Migration[7.2]
  class Component < ApplicationRecord
    self.table_name = "decidim_components"
  end

  SETTINGS_KEY_RENAMES = {
    "steps" => "phases",
    "default_step" => "default_phase"
  }.freeze

  def up
    rename_component_settings(SETTINGS_KEY_RENAMES)
  end

  def down
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
end
