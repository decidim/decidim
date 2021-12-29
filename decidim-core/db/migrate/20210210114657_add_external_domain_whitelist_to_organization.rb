# frozen_string_literal: true

class AddExternalDomainWhitelistToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :external_domain_whitelist, :string, array: true, default: []

    reversible do |direction|
      direction.up do
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::Organization.update_all("external_domain_whitelist = ARRAY['decidim.org', 'github.com']")
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
