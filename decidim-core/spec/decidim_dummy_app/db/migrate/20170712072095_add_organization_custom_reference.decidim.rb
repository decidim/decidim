# This migration comes from decidim (originally 20170215115407)
# frozen_string_literal: true

class AddOrganizationCustomReference < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :reference_prefix, :string

    Decidim::Organization.find_each do |organization|
      organization.update_attribute(:reference_prefix, organization.name[0])
    end

    change_column_null :decidim_organizations, :reference_prefix, false
  end
end
