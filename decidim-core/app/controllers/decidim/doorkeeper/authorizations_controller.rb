# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # Custom Doorkeeper AuthorizationsController to avoid namespace problems.
    class AuthorizationsController < ::Doorkeeper::AuthorizationsController
      include HasSpecificBreadcrumb

      helper_method :oauth_application

      def oauth_application
        @oauth_application ||= Decidim::OAuthApplication.find_by(uid: params[:client_id])
      end

      def breadcrumb_item
        {
          label: t("decidim.doorkeeper.authorizations.new.authorize"),
          active: true
        }
      end
    end
  end
end
