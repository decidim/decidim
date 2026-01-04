# frozen_string_literal: true

class RemoveParticipatoryProcessTypes < ActiveRecord::Migration[7.0]
  def up
    remove_foreign_key :decidim_participatory_processes, :decidim_participatory_process_types
    remove_column :decidim_participatory_processes, :decidim_participatory_process_type_id
    drop_table :decidim_participatory_process_types
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
