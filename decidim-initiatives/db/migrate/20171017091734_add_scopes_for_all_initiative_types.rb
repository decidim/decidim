# frozen_string_literal: true

class AddScopesForAllInitiativeTypes < ActiveRecord::Migration[5.1]
  class Scope < ApplicationRecord
    self.table_name = :decidim_scopes
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations

    has_many :scopes, foreign_key: "decidim_organization_id", class_name: "Scope"
  end

  class InitiativesType < ApplicationRecord
    self.table_name = :decidim_initiatives_types

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Organization"
  end

  class InitiativesTypeScope < ApplicationRecord
    self.table_name = :decidim_initiatives_type_scopes
  end

  def up
    # This migrantion intent is simply to keep seed data at staging
    # environment consistent with the underlying data model. It is
    # not relevant for production environments.
    Organization.find_each do |organization|
      InitiativesType.where(organization:).find_each do |type|
        organization.scopes.each do |scope|
          InitiativesTypeScope.create(
            decidim_initiatives_types_id: type.id,
            decidim_scopes_id: scope.id,
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
