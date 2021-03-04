# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      module AssembliesAdminMenuHelper
        def assemblies_admin_attachments_menu
          @assemblies_admin_attachments_menu ||= simple_menu(target_menu: :assemblies_admin_attachments_menu)
        end

        def admin_assemblies_components_menu
          @admin_assemblies_components_menu ||= simple_menu(target_menu: :admin_assemblies_components_menu, options: { container_options: { id: "components-list" } })
        end
      end
    end
  end
end
