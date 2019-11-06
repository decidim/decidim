# frozen_string_literal: true

class AddSettingsToInitiativesTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_types, :child_scope_threshold_enabled, :boolean, null: false, default: false
    add_column :decidim_initiatives_types, :only_global_scope_enabled, :boolean, null: false, default: false
  end
end
