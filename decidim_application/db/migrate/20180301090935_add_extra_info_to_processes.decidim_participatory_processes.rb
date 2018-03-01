# This migration comes from decidim_participatory_processes (originally 20170126151123)
# frozen_string_literal: true

class AddExtraInfoToProcesses < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_participatory_processes, :domain, :jsonb
    add_column :decidim_participatory_processes, :end_date, :date
    add_column :decidim_participatory_processes, :developer_group, :string
    add_column :decidim_participatory_processes, :scope, :jsonb
  end
end
