class AddExtraInfoToProcesses < ActiveRecord::Migration[5.0]
  def change
      add_column :decidim_participatory_processes, :domain, :jsonb
      add_column :decidim_participatory_processes, :end_date, :date
      add_column :decidim_participatory_processes, :developer_group, :string
      add_column :decidim_participatory_processes, :scope, :string
  end
end
