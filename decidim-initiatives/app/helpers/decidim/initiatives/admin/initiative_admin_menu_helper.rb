# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      module InitiativeAdminMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def admin_initiatives_menu
          @admin_initiatives_menu ||= sidebar_menu(:admin_initiatives_menu)
        end
      end
    end
  end
end
