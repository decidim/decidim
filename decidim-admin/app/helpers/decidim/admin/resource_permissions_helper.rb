# frozen_string_literal: true

module Decidim
  module Admin
    module ResourcePermissionsHelper
      # Public: Render a link to the permissions page for the resource.
      #
      # resource - The resource which permissions are going to be modified
      def dropdown_resource_permissions_link(resource)
        return unless resource.allow_resource_permissions? && allowed_to?(:update, :component, component: resource.component)

        current_participatory_space_admin_proxy = ::Decidim::EngineRouter.admin_proxy(current_participatory_space)
        link_to current_participatory_space_admin_proxy.edit_component_permissions_path(
          current_component.id,
          resource_name: resource.resource_manifest.name,
          resource_id: resource.id
        ), class: "dropdown__button" do
          icon "key-2-line"
          t("actions.permissions", scope: "decidim.admin")
        end
      end

      # Public: Render a link to the permissions page for the resource.
      #
      # resource - The resource which permissions are going to be modified
      def resource_permissions_link(resource)
        return unless resource.allow_resource_permissions? && allowed_to?(:update, :component, component: resource.component)

        current_participatory_space_admin_proxy = ::Decidim::EngineRouter.admin_proxy(current_participatory_space)
        icon_link_to "key-2-line",
                     current_participatory_space_admin_proxy.edit_component_permissions_path(
                       current_component.id,
                       resource_name: resource.resource_manifest.name,
                       resource_id: resource.id
                     ),
                     t("actions.permissions", scope: "decidim.admin"),
                     class: "action-icon--permissions #{"action-icon--highlighted" if resource.permissions.present?}"
      end

      # Public: Render a link to the permissions page for a resource not
      # related with a component and participatory space.
      #
      # resource - The resource which permissions are going to be modified
      def free_resource_permissions_link(resource)
        resource_key = resource.resource_manifest.name.to_sym
        return unless resource.allow_resource_permissions? && allowed_to?(:update, resource_key, resource_key => resource)

        link_to send("edit_#{resource_key}_permissions_path", resource, resource_name: resource.resource_manifest.name), class: "dropdown__button" do
          concat icon "key-2-line"
          concat t("actions.permissions", scope: "decidim.admin")
        end
      end
    end
  end
end
