# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      module AssembliesAdminMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def admin_assemblies_menu
          @admin_assemblies_menu ||= sidebar_menu(:admin_assemblies_menu)
        end
      end
    end
  end
end
