# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # Custom Doorkeeper AuthorizationsController to avoid namespace problems.
    class AuthorizationsController < ::Doorkeeper::AuthorizationsController
      include HasSpecificBreadcrumb

      helper_method :oauth_application, :all_abilities?, :no_abilities?

      def new
        @scopes =
          if pre_auth.authorizable?
            pre_auth.scopes
          else
            []
          end

        super
      end

      def oauth_application
        @oauth_application ||= Decidim::OAuthApplication.find_by(uid: params[:client_id])
      end

      def breadcrumb_item
        {
          label: t("decidim.doorkeeper.authorizations.new.authorize"),
          active: true
        }
      end

      private

      def all_abilities?
        ["profile", "user", "api:read", "api:write"].all? { |scope| @scopes.include?(scope) }
      end

      def no_abilities?
        @scopes.none?
      end
    end
  end
end
