# frozen_string_literal: true

module Decidim
  module Debates
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Debates::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :debate

        case permission_action.action
        when :create
          toggle_allow(can_create_debate?)
        when :read
          toggle_allow(!debate.hidden?)
        when :report
          allow!
        when :edit
          can_edit_debate?
        when :like
          can_endorse_debate?
        when :close
          can_close_debate?
        end

        permission_action
      end

      private

      def can_create_debate?
        authorized?(:create) &&
          current_settings&.creation_enabled? && component.participatory_space.can_participate?(user)
      end

      def can_edit_debate?
        return allow! if debate&.editable_by?(user)

        disallow!
      end

      def can_close_debate?
        return allow! if debate&.closeable_by?(user)

        disallow!
      end

      def can_endorse_debate?
        return disallow! if debate.closed?

        allow!
      end

      def debate
        @debate ||= context.fetch(:debate, nil) || context.fetch(:resource, nil)
      end
    end
  end
end
