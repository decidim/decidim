# frozen_string_literal: true

class ChangeNameOnDecidimOrganizations < ActiveRecord::Migration[6.1]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def up
    rename_column :decidim_organizations, :name, :old_name
    add_column :decidim_organizations, :name, :jsonb, null: false, default: {}

    Organization.reset_column_information

    Organization.find_each do |organization|
      organization.update(name: { organization.default_locale => organization.old_name })
    end
    remove_column :decidim_organizations, :old_name
  end

  def down
    rename_column :decidim_organizations, :name, :old_name
    add_column :decidim_organizations, :name, :string, null: false, default: ""

    Organization.reset_column_information

    Organization.find_each do |organization|
      organization.update(name: organization.old_name[organization.default_locale])
    end
    remove_column :decidim_organizations, :old_name
  end
end
