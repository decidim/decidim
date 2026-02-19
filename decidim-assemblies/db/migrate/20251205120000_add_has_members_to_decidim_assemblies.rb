# frozen_string_literal: true

class AddHasMembersToDecidimAssemblies < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_assemblies, :has_members, :boolean, default: false
  end
end
