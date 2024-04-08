# frozen_string_literal: true

module Decidim
  module Sortitions
    class Permissions < Decidim::DefaultPermissions
      def permissions
        allow_embed_sortition?
        return permission_action unless user

        return Decidim::Sortitions::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        permission_action
      end

      private

      def sortition
        @sortition ||= context.fetch(:sortition, nil) || context.fetch(:resource, nil)
      end

      # As this is a public action, we need to run this before other checks
      def allow_embed_sortition?
        return unless permission_action.action == :embed && permission_action.subject == :sortition && sortition

        allow!
      end
    end
  end
end
