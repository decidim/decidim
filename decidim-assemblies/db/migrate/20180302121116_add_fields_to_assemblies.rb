# frozen_string_literal: true

class AddFieldsToAssemblies < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_assemblies, :purpose_of_action, :jsonb
    add_column :decidim_assemblies, :type_of_assembly, :string
    add_column :decidim_assemblies, :type_of_assembly_other, :jsonb
    add_column :decidim_assemblies, :date_created, :date
    add_column :decidim_assemblies, :created_by, :string
    add_column :decidim_assemblies, :created_by_other, :jsonb
    add_column :decidim_assemblies, :duration, :date
    add_column :decidim_assemblies, :date_of_inclusion, :date
    add_column :decidim_assemblies, :has_closed, :boolean
    add_column :decidim_assemblies, :closing_date, :date
    add_column :decidim_assemblies, :closing_date_reason, :jsonb
    add_column :decidim_assemblies, :internal_organisation, :jsonb
    add_column :decidim_assemblies, :open_field, :string
    add_column :decidim_assemblies, :public_field, :string
    add_column :decidim_assemblies, :transparent_field, :string
    add_column :decidim_assemblies, :special_features, :jsonb
    add_column :decidim_assemblies, :twitter_handler, :string
    add_column :decidim_assemblies, :instagram_handler, :string
    add_column :decidim_assemblies, :facebook_handler, :string
    add_column :decidim_assemblies, :youtube_handler, :string
    add_column :decidim_assemblies, :github_handler, :string
  end
end
