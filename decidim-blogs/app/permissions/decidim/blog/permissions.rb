# frozen_string_literal: true

module Decidim
  module Blog
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless permission_action.subject == :blogpost || permission_action.subject == :post

        if permission_action.scope == :public
          if permission_action.action.in?([:update, :destroy])
            toggle_allow(can_manage_post)
            return permission_action
          end

          if permission_action.action == :create
            toggle_allow(can_create_post)
            return permission_action
          end

          allow!
          return permission_action
        end

        return permission_action if permission_action.scope != :admin

        if permission_action.action.in?([:update, :destroy])
          toggle_allow(can_manage_post)
          return permission_action
        end

        allow!
        permission_action
      end

      def post
        @post ||= context.fetch(:blogpost, nil)
      end

      def current_component
        @current_component ||= context.fetch(:current_component, nil)
      end

      def can_create_post
        current_component&.participatory_space.is_a?(Decidim::Initiative) &&
          initiative_authorship? &&
          current_component&.participatory_space&.published? &&
          current_component&.published?
      end

      def can_manage_post
        can_create_post && post.author == user
      end

      def initiative_authorship?
        current_component&.participatory_space&.has_authorship?(user)
      end
    end
  end
end
