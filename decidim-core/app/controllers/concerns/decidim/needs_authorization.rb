# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need authorization to work.
  module NeedsAuthorization
    extend ActiveSupport::Concern

    included do
      check_authorization

      rescue_from CanCan::AccessDenied, with: :user_not_authorized
      rescue_from ActionAuthorization::Unauthorized, with: :user_not_authorized

      private

      # Overwrites `cancancan`'s method to point to the correct ability class,
      # since the gem expects the ability class to be in the root namespace.
      def current_ability
        @current_ability ||= current_ability_klass.new(current_user, ability_context)
      end

      def ability_context
        {
          current_settings: try(:current_settings),
          feature_settings: try(:feature_settings),
          current_organization: try(:current_organization),
          current_feature: try(:current_feature)
        }
      end

      # Handles the case when a user visits a path that is not allowed to them.
      # Redirects the user to the root path and shows a flash message telling
      # them they are not authorized.
      def user_not_authorized
        flash[:alert] = t("actions.unauthorized", scope: "decidim.core")
        redirect_to(request.referer || user_not_authorized_path)
      end

      def user_not_authorized_path
        raise NotImplementedError
      end
    end
  end
end
