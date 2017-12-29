module Decidim
  class NavbarLink < ApplicationRecord
    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    scope :current_organization_links, -> (organization){ where(decidim_organization_id: organization.id) }
  end
end
