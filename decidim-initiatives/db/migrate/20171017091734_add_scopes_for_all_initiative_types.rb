# frozen_string_literal: true

class AddScopesForAllInitiativeTypes < ActiveRecord::Migration[5.1]
  def up
    # This migrantion intent is simply to keep seed data at staging
    # environment consistent with the underlying data model. It is
    # not relevant for production environments.
    Decidim::Organization.find_each do |organization|
      Decidim::InitiativesType.where(organization: organization).find_each do |type|
        organization.scopes.each do |scope|
          Decidim::InitiativesTypeScope.create(
            type: type,
            scope: scope,
            supports_required: 1000
          )
        end
      end
    end
  end

  def down
    Decidim::InitiativesTypeScope.destroy_all
  end
end
