# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to update the current organization from the admin
    # dashboard.
    #
    class OrganizationForm < Form
      include TranslatableAttributes

      mimic :organization

      attribute :name, String
      attribute :twitter_handler, String
      attribute :default_locale, String
      attribute :homepage_image
      attribute :logo
      attribute :show_statistics

      translatable_attribute :description, String
      translatable_attribute :welcome_text, String

      validates :name, presence: true
      validates :default_locale, presence: true
      validates :default_locale, inclusion: { in: :available_locales }

      private

      def available_locales
        current_organization.available_locales
      end
    end
  end
end
