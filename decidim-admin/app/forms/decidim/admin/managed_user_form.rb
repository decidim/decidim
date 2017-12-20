# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to create managed users from the admin dashboard.
    #
    # This form will contain a dynamic attribute for the user authorization.
    # This authorization will be selected by the admin user if more than one exists.
    class ManagedUserForm < Form
      attribute :name, String

      validates :name, presence: true

      def initialize(attributes)
        extend(Virtus.model)

        # Set the authorization dynamic attribute as a nested form class based on the handler name.
        attribute(:authorization, Decidim::AuthorizationHandler.handler_for(attributes.dig(:authorization, :handler_name)))

        super
      end
    end
  end
end
