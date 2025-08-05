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
                           ::Decidim::Permissions,
                           ::Decidim::Api::Permissions)

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

      def context
        {
          current_organization:,
          current_user: api_user,
          scopes: api_scopes
        }
      end

      def api_user
        @api_user = current_api_user || current_user
      end

      # Determines the scopes for the user for API requests.
      #
      # @return [Doorkeeper::OAuth::Scopes]
      def api_scopes
        if doorkeeper_token
          doorkeeper_token.scopes
        elsif api_user.present?
          # In case a doorkeeper token is not available, we assume the user is
          # either:
          # - A regular authenticated user in Decidim using the API locally
          #   from within Decidim using the system with the cookie based
          #   authentication
          # - A Decidim::Api::ApiUser authenticated through the `/api/sign_in`
          #   endpoint for machine-to-machine integrations using the system with
          #   the assigned JSON Web Token (JWT).
          #
          # In both of these cases we assume all scopes as the user does not
          # request any specific scopes during the authentication process and
          # the user would be anyways able to perform any actions they are
          # normally allowed to perform within the regular user interface.
          ::Doorkeeper::OAuth::Scopes.from_array(::Doorkeeper.config.scopes.all)
        else
          # In case no user is present, we only allow the user to read the API.
          ::Doorkeeper::OAuth::Scopes.from_string("api:read")
        end
      end
    end
  end
end
