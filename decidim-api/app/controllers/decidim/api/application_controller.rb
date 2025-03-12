# frozen_string_literal: true

module Decidim
  module Api
    # Base controller for `decidim-api`. All other controllers inherit from this.
    class ApplicationController < ::DecidimController
      skip_before_action :verify_authenticity_token
      before_action :ensure_api_authenticated!

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

      private

      def ensure_api_authenticated!
        return unless Decidim::Api.force_api_authentication
        return if user_signed_in?

        respond_to do |format|
          format.html do
            flash[:warning] = t("actions.login_before_access", scope: "decidim.core")
            store_location_for(:user, request.path)
            redirect_to decidim.new_user_session_path
          end
          format.json do
            render json: { error: "Access denied" }, status: :unauthorized
          end
        end
      end
    end
  end
end
