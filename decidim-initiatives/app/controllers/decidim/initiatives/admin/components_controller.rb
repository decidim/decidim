# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing the Initiative's Components in the
      # admin panel.
      class ComponentsController < Decidim::Admin::ComponentsController
        layout "decidim/admin/initiative"

        include NeedsInitiative
        include Decidim::Admin::ParticipatorySpaceAdminBreadcrumb

        add_breadcrumb_item_from_menu :admin_initiative_menu
      end
    end
  end
end
