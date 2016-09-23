# frozen_string_literal: true
module Decidim
  module System
    # A form object used to create organizations from the system dashboard.
    #
    class RegisterOrganizationForm < UpdateOrganizationForm
      mimic :organization

      attribute :organization_admin_email, String

      validates :organization_admin_email, presence: true
    end
  end
end
