# frozen_string_literal: true

class AddOrganizationCustomReference < ActiveRecord::Migration[5.0]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def change
    add_column :decidim_organizations, :reference_prefix, :string

    Organization.find_each do |organization|
      organization.update_attributes!(reference_prefix: organization.name[0])
    end

    change_column_null :decidim_organizations, :reference_prefix, false
  end
end
