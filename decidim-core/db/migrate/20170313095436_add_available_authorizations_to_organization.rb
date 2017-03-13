class AddAvailableAuthorizationsToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :available_authorizations, :string, array: true, default: []
  end
end
