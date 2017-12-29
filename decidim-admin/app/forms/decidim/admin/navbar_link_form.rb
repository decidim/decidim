# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update scopes.
    class NavbarLinkForm < Form
      include TranslatableAttributes

      translatable_attribute :title, String
      attribute :link, String
      attribute :organization_id, Integer

      validates :title, translatable_presence: true
      validates :organization_id, :link, presence: true

    end
  end
end
