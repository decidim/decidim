# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to impersonate managed users from the admin dashboard.
    #
    # This form will contain a dynamic attribute for the user authorization.
    # This authorization will be selected by the admin user if more than one exists.
    class ImpersonateManagedUserForm < Form
      def initialize(attributes)
        extend(Virtus.model)

        # Set the authorization dynamic attribute as a nested form class based on the handler name.
        attribute(:authorization, Decidim::AuthorizationHandler.handler_for(attributes.dig(:authorization, :handler_name)))

        super
      end
    end
  end
end
