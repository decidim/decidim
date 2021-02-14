# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      module InitiativeAdminMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def admin_initiatives_menu
          Decidim::MenuRegistry.destroy(:admin_initiatives_menu)
          Decidim.menu :admin_initiatives_menu do |menu|
            menu.item I18n.t("menu.initiatives", scope: "decidim.admin"),
                      decidim_admin_initiatives.initiatives_path,
                      position: 1.0,
                      active: is_active_link?(decidim_admin_initiatives.initiatives_path),
                      if: allowed_to?(:index, :initiative)

            menu.item I18n.t("menu.initiatives_types", scope: "decidim.admin"),
                      decidim_admin_initiatives.initiatives_types_path,
                      active: is_active_link?(decidim_admin_initiatives.initiatives_types_path),
                      if: allowed_to?(:manage, :initiative_type)
          end
          @admin_initiatives_menu ||= sidebar_menu(:admin_initiatives_menu)
        end
      end
    end
  end
end
