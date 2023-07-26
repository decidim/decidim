# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing initiatives types
      # permissions in the admin panel.
      class InitiativesTypesPermissionsController < Decidim::Admin::ResourcePermissionsController
        include Decidim::TranslatableAttributes
        include HasSpecificBreadcrumb

        add_breadcrumb_item_from_menu :admin_initiatives_menu

        layout "decidim/admin/initiatives"

        register_permissions(::Decidim::Initiatives::Admin::InitiativesTypesPermissionsController,
                             ::Decidim::Initiatives::Permissions,
                             ::Decidim::Admin::Permissions)

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Initiatives::Admin::InitiativesTypesPermissionsController)
        end

        private

        def breadcrumb_item
          [
            {
              label: t("initiatives_types", scope: "decidim.admin.menu"),
              url: initiatives_types_path,
              active: false
            },
            {
              label: translated_attribute(resource.title),
              url: edit_initiatives_type_path(resource),
              active: false
            },
            {
              label: t("permissions", scope: "decidim.admin.actions"),
              active: true
            }
          ]
        end
      end
    end
  end
end
