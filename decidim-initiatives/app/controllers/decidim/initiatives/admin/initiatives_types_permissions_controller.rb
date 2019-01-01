# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing initiatives types
      # permissions in the admin panel.
      class InitiativesTypesPermissionsController < Decidim::Admin::ResourcePermissionsController
        layout "decidim/admin/initiatives"

        def permission_class_chain
          [
            Decidim::Initiatives::Permissions,
            Decidim::Admin::Permissions
          ]
        end
      end
    end
  end
end
