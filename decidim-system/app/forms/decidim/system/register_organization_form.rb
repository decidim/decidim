# frozen_string_literal: true

require "decidim/translatable_attributes"

module Decidim
  module System
    # A form object used to create organizations from the system dashboard.
    #
    class RegisterOrganizationForm < UpdateOrganizationForm
      include JsonbAttributes
      mimic :organization

      attribute :organization_admin_email, String
      attribute :organization_admin_name, String
      attribute :available_locales, Array
      attribute :default_locale, String
      attribute :reference_prefix
      attribute :users_registration_mode, String
      attribute :force_users_to_authenticate_before_access_organization, Boolean

      validates :organization_admin_email, :organization_admin_name, :name, :host, :reference_prefix, :users_registration_mode, presence: true
      validates :available_locales, presence: true
      validates :default_locale, presence: true
      validates :default_locale, inclusion: { in: :available_locales }
      validates :users_registration_mode, inclusion: { in: Decidim::Organization.users_registration_modes }
    end
  end
end
