# frozen_string_literal: true

module Decidim
  module Admin
    module ResourcePermissionsHelper
      # Public: Render a link to the permissions page for the resource.
      #
      # resource - The resource which permissions are going to be modified
      def resource_permissions_link(resource)
        return unless resource.allow_resource_permissions? && allowed_to?(:update, :component, component: resource.component)

        current_participatory_space_admin_proxy = ::Decidim::EngineRouter.admin_proxy(current_participatory_space)
        icon_link_to "key",
                     current_participatory_space_admin_proxy.edit_component_permissions_path(
                       current_component.id,
                       resource_name: resource.resource_manifest.name,
                       resource_id: resource.id
                     ),
                     t("actions.permissions", scope: "decidim.admin"),
                     class: "action-icon--permissions #{"action-icon--highlighted" if resource.permissions.present?}"
      end
    end
  end
end
