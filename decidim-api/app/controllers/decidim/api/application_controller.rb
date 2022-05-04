# frozen_string_literal: true

module Decidim
  module Api
    # Base controller for `decidim-api`. All other controllers inherit from this.
    class ApplicationController < ::DecidimController
      skip_before_action :verify_authenticity_token
      include NeedsOrganization
      include UseOrganizationTimeZone
      include NeedsPermission
      include ImpersonateUsers
      include ForceAuthentication
      include DisableRedirectionToExternalHost

      register_permissions(::Decidim::Api::ApplicationController,
                           ::Decidim::Permissions)

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Api::ApplicationController)
      end

      def permission_scope
        :public
      end
    end
  end
end
