# frozen_string_literal: true
require "decidim/translatable_attributes"

module Decidim
  module System
    # A form object used to create organizations from the system dashboard.
    #
    class RegisterOrganizationForm < UpdateOrganizationForm
      include TranslatableAttributes

      mimic :organization

      attribute :organization_admin_email, String

      validates :organization_admin_email, presence: true

      translatable_attribute :description, String
    end
  end
end
