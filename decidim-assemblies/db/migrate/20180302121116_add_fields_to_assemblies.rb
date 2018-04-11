# frozen_string_literal: true

class AddFieldsToAssemblies < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_assemblies, :purpose_of_action, :jsonb
    add_column :decidim_assemblies, :composition, :jsonb
    add_column :decidim_assemblies, :assembly_type, :string
    add_column :decidim_assemblies, :assembly_type_other, :jsonb
    add_column :decidim_assemblies, :creation_date, :date
    add_column :decidim_assemblies, :created_by, :string
    add_column :decidim_assemblies, :created_by_other, :jsonb
    add_column :decidim_assemblies, :duration, :date
    add_column :decidim_assemblies, :included_at, :date
    add_column :decidim_assemblies, :closing_date, :date
    add_column :decidim_assemblies, :closing_date_reason, :jsonb
    add_column :decidim_assemblies, :internal_organisation, :jsonb
    add_column :decidim_assemblies, :is_transparent, :boolean, default: true
    add_column :decidim_assemblies, :special_features, :jsonb
    add_column :decidim_assemblies, :twitter_handler, :string
    add_column :decidim_assemblies, :instagram_handler, :string
    add_column :decidim_assemblies, :facebook_handler, :string
    add_column :decidim_assemblies, :youtube_handler, :string
    add_column :decidim_assemblies, :github_handler, :string
  end
end
