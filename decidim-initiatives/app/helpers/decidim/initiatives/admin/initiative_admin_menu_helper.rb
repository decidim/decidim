# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      module InitiativeAdminMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def admin_initiatives_menu
          @admin_initiatives_menu ||= sidebar_menu(:admin_initiatives_menu)
        end

        def admin_initiatives_components_menu
          @admin_initiatives_components_menu ||= simple_menu(:admin_initiatives_components_menu)
        end

        def decidim_initiative_menu
          @decidim_initiative_menu ||= sidebar_menu(:decidim_initiative_menu)
        end
      end
    end
  end
end
