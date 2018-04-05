# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to work with the permissions system
  module NeedsPermission
    extend ActiveSupport::Concern

    included do
      helper_method :allowed_to?

      skip_authorization_check

      class ::Decidim::ActionForbidden < StandardError
      end

      rescue_from Decidim::ActionForbidden, with: :user_not_authorized

      def permissions_context
        {
          current_settings: try(:current_settings),
          component_settings: try(:component_settings),
          current_organization: try(:current_organization),
          current_component: try(:current_component)
        }
      end

      def enforce_permission_to(action, subject, extra_context = {})
        raise Decidim::ActionForbidden unless allowed_to?(action, subject, extra_context)
      end

      def allowed_to?(action, subject, extra_context = {})
        permission_class.new(
          current_user,
          Decidim::PermissionAction.new(scope: permission_scope, action: action, subject: subject),
          permissions_context.merge(extra_context)
        ).allowed?
      end

      def permission_class
        raise "Please, make this method return a class"
      end

      def permission_scope
        raise "Please, make this method return a symbol"
      end

      def current_ability
        @current_ability ||= FakeAbility.new(current_user, permissions_context)
      end

      class FakeAbility
        include CanCan::Ability

        def initialize(*); end
      end
    end
  end
end
