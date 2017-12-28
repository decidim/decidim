# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update scopes.
    class NavbarLinkForm < Form
      include TranslatableAttributes

      translatable_attribute :title, String
      attribute :link, String
      attribute :organization, Decidim::Organization

      validates :title, translatable_presence: true
      validates :organization, :link, presence: true

    end
  end
end
