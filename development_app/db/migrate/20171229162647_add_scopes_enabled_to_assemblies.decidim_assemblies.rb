# This migration comes from decidim_assemblies (originally 20170822153055)
# frozen_string_literal: true

class AddScopesEnabledToAssemblies < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_assemblies, :scopes_enabled, :boolean, null: false, default: true
  end
end
