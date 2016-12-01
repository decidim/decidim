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
      attribute :organization_admin_name, String
      attribute :available_locales, Array
      attribute :default_locale, String
      attribute :homepage_image
      translatable_attribute :description, String
      translatable_attribute :welcome_text, String

      validates :welcome_text, presence: true
      validates :organization_admin_email, :organization_admin_name, :name, :host, presence: true
      validates :available_locales, presence: true
      validates :default_locale, presence: true
      validates :default_locale, inclusion: { in: :available_locales }
    end
  end
end
