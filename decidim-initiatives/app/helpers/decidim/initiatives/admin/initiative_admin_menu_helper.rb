# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      module InitiativeAdminMenuHelper
        def admin_initiatives_components_menu
          @admin_initiatives_components_menu ||= simple_menu(target_menu: :admin_initiatives_components_menu, options: { container_options: { id: "components-list" } })
        end
      end
    end
  end
end
