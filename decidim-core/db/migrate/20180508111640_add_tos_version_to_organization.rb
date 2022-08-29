# frozen_string_literal: true

class AddTosVersionToOrganization < ActiveRecord::Migration[5.1]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def up
    add_column :decidim_organizations, :tos_version, :datetime
    Organization.find_each do |organization|
      tos_version = Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization:).updated_at
      organization.update(tos_version:)
    end
  end

  def down
    remove_columns :decidim_organizations, :tos_version
  end
end
