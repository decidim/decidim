# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need authorization to work.
  module NeedsAuthorization
    extend ActiveSupport::Concern

    included do
      check_authorization

      rescue_from CanCan::AccessDenied, with: :user_not_authorized

      private

      # Overwrites `cancancan`'s method to point to the correct ability class,
      # since the gem expects the ability class to be in the root namespace.
      def current_ability
        @current_ability ||= Decidim::Ability.new(current_user)
      end

      # Handles the case when a user visits a path that is not allowed to them.
      # Redirects the user to the root path and shows a flash message telling
      # them they are not authorized.
      def user_not_authorized
        flash[:alert] = t("actions.unauthorized", scope: "decidim.core")
        redirect_to(request.referrer || user_not_authorized_path)
      end

      def user_not_authorized_path
        raise NotImplementedError
      end
    end
  end
end
