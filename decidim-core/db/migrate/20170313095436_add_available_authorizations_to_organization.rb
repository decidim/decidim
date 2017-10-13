# frozen_string_literal: true

class AddAvailableAuthorizationsToOrganization < ActiveRecord::Migration[5.0]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def change
    add_column :decidim_organizations, :available_authorizations, :string, array: true, default: []

    handlers = Decidim.authorization_handlers
    Organization.find_each do |org|
      org.update_attributes!(available_authorizations: handlers)
    end
  end
end
