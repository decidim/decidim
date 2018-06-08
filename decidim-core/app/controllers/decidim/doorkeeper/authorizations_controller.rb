# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # Custom Doorkeeper AuthorizationsController to avoid namespace problems.
    class AuthorizationsController < ::Doorkeeper::AuthorizationsController
      helper_method :oauth_application

      def oauth_application
        @oauth_application ||= Decidim::OAuthApplication.find_by(uid: params[:client_id])
      end
    end
  end
end
