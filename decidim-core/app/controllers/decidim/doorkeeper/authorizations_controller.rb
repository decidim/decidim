# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # Custom Doorkeeper AuthorizationsController to avoid namespace problems.
    class AuthorizationsController < ::Doorkeeper::AuthorizationsController
      include HasSpecificBreadcrumb

      before_action :set_oauth_application

      helper_method :oauth_application, :all_abilities?

      attr_reader :oauth_application

      def new
        @scopes =
          if pre_auth.authorizable?
            pre_auth.scopes
          else
            []
          end

        super
      end

      def breadcrumb_item
        {
          label: t("decidim.doorkeeper.authorizations.new.authorize"),
          active: true
        }
      end

      private

      def set_oauth_application
        return if params[:client_id].blank?

        @oauth_application = current_organization.oauth_applications.find_by!(uid: params.expect(:client_id))
      end

      def all_abilities?
        %w(api:read api:write).all? { |scope| @scopes.include?(scope) } &&
          %w(profile user).any? { |scope| @scopes.include?(scope) }
      end
    end
  end
end
