# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing the Initiative's Component
      # permissions in the admin panel.
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include InitiativeAdmin

        protected
        def allowed_params
          super.push(:initiative_slug)
        end
      end
    end
  end
end
