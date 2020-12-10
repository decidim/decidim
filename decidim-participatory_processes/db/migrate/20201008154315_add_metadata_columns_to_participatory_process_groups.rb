# frozen_string_literal: true

class AddMetadataColumnsToParticipatoryProcessGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_process_groups, :group_url, :string
    add_column :decidim_participatory_process_groups, :developer_group, :jsonb
    add_column :decidim_participatory_process_groups, :local_area, :jsonb
    add_column :decidim_participatory_process_groups, :meta_scope, :jsonb
    add_column :decidim_participatory_process_groups, :target, :jsonb
    add_column :decidim_participatory_process_groups, :participatory_scope, :jsonb
    add_column :decidim_participatory_process_groups, :participatory_structure, :jsonb
  end
end
