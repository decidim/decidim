# frozen_string_literal: true

class AddDeletedAtToDecidimAssemblies < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_assemblies, :deleted_at, :datetime
    add_index :decidim_assemblies, :deleted_at
  end
end
