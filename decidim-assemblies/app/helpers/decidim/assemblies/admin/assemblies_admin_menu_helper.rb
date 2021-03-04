# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      module AssembliesAdminMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def assemblies_admin_attachments_menu
          @assemblies_admin_attachments_menu ||= simple_menu(:assemblies_admin_attachments_menu)
        end

        def admin_assemblies_components_menu
          @admin_assemblies_components_menu ||= simple_menu(:admin_assemblies_components_menu)
        end

        def assemblies_admin_menu
          @assemblies_admin_menu ||= sidebar_menu(:assemblies_admin_menu)
        end

        def admin_assemblies_menu
          @admin_assemblies_menu ||= sidebar_menu(:admin_assemblies_menu)
        end
      end
    end
  end
end
