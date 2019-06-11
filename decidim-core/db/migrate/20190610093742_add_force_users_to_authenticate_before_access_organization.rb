# frozen_string_literal: true

class AddForceUsersToAuthenticateBeforeAccessOrganization < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.transaction do
      add_column :decidim_organizations,
                 :force_users_to_authenticate_before_access_organization,
                 :boolean,
                 default: nil

      execute <<~SQL
        ALTER TABLE decidim_organizations ALTER COLUMN force_users_to_authenticate_before_access_organization SET DEFAULT false;
      SQL
    end

    Decidim::Organization.find_each do |organization|
      organization.update(force_users_to_authenticate_before_access_organization: false)
    end

    ActiveRecord::Base.transaction do
      execute <<~SQL
        ALTER TABLE decidim_organizations ALTER COLUMN force_users_to_authenticate_before_access_organization SET NOT NULL;
      SQL
    end
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :decidim_organizations, :force_users_to_authenticate_before_access_organization
    end
  end
end
