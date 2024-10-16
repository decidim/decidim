# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to work with the permissions system
  module NeedsPermission
    extend ActiveSupport::Concern
    include RegistersPermissions

    included do
      helper_method :allowed_to?, :admin_allowed_to?

      class ::Decidim::ActionForbidden < StandardError
      end

      rescue_from Decidim::ActionForbidden, with: :user_has_no_permission

      # Handles the case when a user visits a path that is not allowed to them.
      # Redirects the user to the root path and shows a flash message telling
      # them they are not authorized.
      def user_has_no_permission
        flash[:alert] = t("actions.unauthorized", scope: "decidim.core")
        redirect_to(user_has_no_permission_referer || user_has_no_permission_path)
      end

      def user_has_no_permission_referer
        return unless user_signed_in?
        return if request.referer == request.original_url

        request.referer
      end

      def user_has_no_permission_path
        raise NotImplementedError
      end

      def permissions_context
        {
          current_settings: try(:current_settings),
          component_settings: try(:component_settings),
          current_organization: try(:current_organization),
          current_component: try(:current_component),
          share_token: try(:store_share_token)
        }
      end

      def enforce_permission_to(action, subject, extra_context = {})
        if Rails.env.development?
          Rails.logger.debug "==========="
          Rails.logger.debug [permission_scope, action, subject, permission_class_chain].map(&:inspect).join("\n")
          Rails.logger.debug "==========="
        end

        raise Decidim::ActionForbidden unless allowed_to?(action, subject, extra_context)
      end

      # rubocop:disable Metrics/ParameterLists
      def allowed_to?(action, subject, extra_context = {}, chain = permission_class_chain, user = current_user, scope = nil)
        scope ||= permission_scope
        permission_action = Decidim::PermissionAction.new(scope:, action:, subject:)

        chain.inject(permission_action) do |current_permission_action, permission_class|
          permission_class.new(
            user,
            current_permission_action,
            permissions_context.merge(extra_context)
          ).permissions
        end.allowed?
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end
      # rubocop:enable Metrics/ParameterLists

      def admin_allowed_to?(action, subject, extra_context = {}, chain = permission_class_chain, user = current_user)
        allowed_to?(action, subject, extra_context, chain, user, :admin)
      end

      def permission_class_chain
        raise "Please, make this method return an array of permission classes"
      end

      def permission_scope
        raise "Please, make this method return a symbol"
      end
    end
  end
end
