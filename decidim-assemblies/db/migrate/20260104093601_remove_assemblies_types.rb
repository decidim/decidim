# frozen_string_literal: true

class RemoveAssembliesTypes < ActiveRecord::Migration[7.0]
  def up
    remove_column :decidim_assemblies, :decidim_assemblies_type_id, if_exists: true
    drop_table :decidim_assemblies_types, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
