# frozen_string_literal: true

class AddForceUsersToAuthenticateBeforeAccessOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations,
                 :force_users_to_authenticate_before_access_organization,
                 :boolean,
                 default: :false
  end
  
  # def up
  #   ActiveRecord::Base.transaction do
  #     add_column :decidim_organizations,
  #                :force_users_to_authenticate_before_access_organization,
  #                :boolean,
  #                default: :false
  #   end

  #   # Decidim::Organization.find_each do |organization|
  #   #   organization.update(force_users_to_authenticate_before_access_organization: false)
  #   # end
  # end

  # def down
  #   ActiveRecord::Base.transaction do
  #     remove_column :decidim_organizations, :force_users_to_authenticate_before_access_organization
  #   end
  # end
end
