# frozen_string_literal: true

module Decidim
  module Api
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless permission_action.scope == :admin

        unless user || !user.admin? || !admin_terms_accepted?
          disallow!
          return permission_action
        end

        if permission_action.subject == :blob
          case permission_action.action
          when :create
            allow!
          when :update, :delete
            blob.present?
          end
        end

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
    end
  end
end
