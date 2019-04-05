class AddMetadataFieldsToParticipatoryProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :cost, :decimal
    add_column :decidim_participatory_processes, :has_summary_record, :boolean
  end
end
