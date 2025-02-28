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

        return permission_action unless permission_action.scope == :admin

        if permission_action.action.in?([:update, :destroy])
          toggle_allow(admin_can_manage_post)
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
        current_component&.participatory_space&.published? &&
          current_component&.published? &&
          (creation_enabled_for_participants? || initiative_authorship?)
      end

      def can_manage_post
        return false unless post&.author

        can_create_post && admin_can_manage_post
      end

      def admin_can_manage_post
        return false unless post&.author

        case post.author
        when Decidim::User
          post.author == user
        when Decidim::Organization
          space_admin?
        else
          false
        end
      end

      def space_admin?
        space_admins.include?(user)
      end

      def creation_enabled_for_participants?
        component_settings&.creation_enabled_for_participants? &&
          current_component&.participatory_space&.can_participate?(user)
      end

      def space_admins
        participatory_space = current_component&.participatory_space

        return [] unless participatory_space

        @space_admins ||= begin
          space_admins = if participatory_space.respond_to?(:user_roles)
                           participatory_space.user_roles(:admin)&.collect(&:user)
                         else
                           []
                         end
          global_admins = current_component.organization.admins
          (global_admins + space_admins).uniq
        end
      end

      def initiative_authorship?
        return false unless user

        Decidim.module_installed?("initiatives") &&
          current_component&.participatory_space.is_a?(Decidim::Initiative) &&
          current_component&.participatory_space&.has_authorship?(user)
      end
    end
  end
end
