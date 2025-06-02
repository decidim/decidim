# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to update the current organization appearance from the admin
    # dashboard.
    #
    class OrganizationAppearanceForm < Form
      mimic :organization

      attribute :header_snippets, String

      alias organization current_organization
    end
  end
end
