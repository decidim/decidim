# frozen_string_literal: true

class AddExternalDomainWhitelistToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :external_domain_whitelist, :string, array: true, default: []

    reversible do |direction|
      direction.up do
        Decidim::Organization.find_each do |organization|
          organization.update!(external_domain_whitelist: ["decidim.org", "github.com"])
        end
      end
    end
  end
end
