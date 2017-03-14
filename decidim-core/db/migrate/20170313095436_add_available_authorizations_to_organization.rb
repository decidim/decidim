class AddAvailableAuthorizationsToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :available_authorizations, :string, array: true, default: []

    handlers = Decidim.authorization_handlers.map(&:name)
    Decidim::Organization.find_each do |org|
      org.update_attributes(available_authorizations: handlers)
    end
  end
end
