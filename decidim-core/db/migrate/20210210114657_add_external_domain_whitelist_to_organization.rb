# frozen_string_literal: true

class AddExternalDomainWhitelistToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :external_domain_whitelist, :string, array: true, default: []
  end
end
