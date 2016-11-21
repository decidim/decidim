# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to update the current organization from the admin
    # dashboard.
    #
    class OrganizationForm < Rectify::Form
      include TranslatableAttributes

      mimic :organization

      attribute :current_organization, Decidim::Organization
      attribute :current_user, Decidim::User

      attribute :name, String
      attribute :default_locale, String
      translatable_attribute :description, String

      validates :name, presence: true
      validates :default_locale, presence: true
      validates :default_locale, inclusion: { in: :available_locales }
      validates :description, translatable_presence: true

      private

      def available_locales
        current_organization.available_locales
      end
    end
  end
end
