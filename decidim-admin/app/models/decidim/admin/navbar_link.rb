module Decidim::Admin
  class NavbarLink < ApplicationRecord
    scope :current_organization_links, -> (organization){ where(decidim_organization_id: organization.id) }
  end
end
