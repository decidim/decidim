# frozen_string_literal: true

module Decidim
  module Surveys
    class Permissions
      def initialize(user, permission_action, context)
        @user = user
        @permission_action = permission_action
        @context = context
      end

      def allowed?
        # Stop checks if the user is not authorized to perform the
        # permission_action for this space
        return false unless spaces_allows_user?
        return false unless user

        return false if permission_action.scope != :public

        return false if permission_action.subject != :survey

        return true if case permission_action.action
                       when :answer
                         authorized?(:answer)
                       else
                         false
                       end

        false
      end

      private

      attr_reader :user, :permission_action, :context

      def spaces_allows_user?
        return unless space.manifest.permissions_class
        space.manifest.permissions_class.new(user, permission_action, context).allowed?
      end

      def current_settings
        @current_settings ||= context.fetch(:current_settings, nil)
      end

      def component_settings
        @component_settings ||= context.fetch(:component_settings, nil)
      end

      def component
        @component ||= context.fetch(:current_component)
      end

      def space
        @space ||= component.participatory_space
      end

      def authorized?(permission_action)
        return unless component

        ActionAuthorizer.new(user, component, permission_action).authorize.ok?
      end
    end
  end
end
