# frozen_string_literal: true
module Decidim
  module Devise
    # This controller customizes the behaviour of Devise's
    # RegistrationsController so we can specify a custom layout.
    class RegistrationsController < ::Devise::RegistrationsController
      include Decidim::NeedsOrganization
      layout "application"

      protected

      # Called before resource.save
      def build_resource(hash = nil)
        super(hash)
        resource.organization = current_organization
      end
    end
  end
end
