# frozen_string_literal: true

class AddAccessModeToAssemblies < ActiveRecord::Migration[6.1]
  def up
    add_column :decidim_assemblies, :access_mode, :integer, null: false, default: 0
  end

  def down
    remove_column :decidim_assemblies, :access_mode
  end
end
