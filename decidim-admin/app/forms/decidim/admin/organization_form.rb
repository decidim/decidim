# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to update the current organization from the admin
    # dashboard.
    #
    class OrganizationForm < Rectify::Form
      include TranslatableAttributes

      mimic :organization

      attribute :name, String
      attribute :available_locales, Array
      attribute :default_locale, String
      translatable_attribute :description, String

      validates :name, presence: true
      validates :available_locales, presence: true
      validates :default_locale, presence: true
      validates :default_locale, inclusion: { in: :available_locales }
      translatable_validates :description, presence: true
    end
  end
end
