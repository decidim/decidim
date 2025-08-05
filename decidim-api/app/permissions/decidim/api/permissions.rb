# frozen_string_literal: true

module Decidim
  module Api
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user
        return permission_action unless user.admin?
        return permission_action if permission_action.scope != :admin
        return permission_action unless user.admin_terms_accepted?

        permission_action.allow! if can_perform_actions_on?(:blob, blob)

        permission_action
      end

      private

      def blob
        @blob ||= context.fetch(:blob, nil)
      end

      def user
        @user ||= context.fetch(:current_user)
      end

      def admin_terms_accepted?
        user&.admin_terms_accepted?
      end

      def can_perform_actions_on?(subject, resource)
        return unless permission_action.subject == subject

        case permission_action.action
        when :create
          true
        when :destroy, :update
          resource.present?
        else
          false
        end
      end
    end
  end
end
