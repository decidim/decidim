# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # Custom Doorkeeper AuthorizationsController to avoid namespace problems.
    class AuthorizationsController < ::Doorkeeper::AuthorizationsController
      include HasSpecificBreadcrumb

      before_action :validate_application_organization

      helper_method :oauth_application, :all_abilities?

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
        @oauth_application ||= current_organization.oauth_applications.find_by(uid: params[:client_id])
      end

      def breadcrumb_item
        {
          label: t("decidim.doorkeeper.authorizations.new.authorize"),
          active: true
        }
      end

      private

      def validate_application_organization
        return if params[:client_id].blank?
        return if current_organization.oauth_applications.exists?(uid: params[:client_id])

        raise ActiveRecord::RecordNotFound
      end

      def all_abilities?
        %w(api:read api:write).all? { |scope| @scopes.include?(scope) } &&
          %w(profile user).any? { |scope| @scopes.include?(scope) }
      end
    end
  end
end
