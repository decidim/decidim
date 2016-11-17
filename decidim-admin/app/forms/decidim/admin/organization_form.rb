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
      translatable_attribute :description, String

      validates :name, presence: true
      translatable_validates :description, presence: true
    end
  end
end
