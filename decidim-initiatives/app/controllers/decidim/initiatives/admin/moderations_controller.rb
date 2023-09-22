# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # This controller allows admins to manage moderations in an initiative.
      class ModerationsController < Decidim::Admin::ModerationsController
        include InitiativeAdmin

        add_breadcrumb_item_from_menu :admin_initiative_menu

        def permissions_context
          super.merge(current_participatory_space:)
        end
      end
    end
  end
end
