# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing initiatives
      # permissions in the admin panel.
      class InitiativesPermissionsController < Decidim::Admin::ResourcePermissionsController
        include Decidim::Initiatives::NeedsInitiative

        layout "decidim/admin/initiatives"

        register_permissions(::Decidim::Initiatives::Admin::InitiativesPermissionsController,
                             ::Decidim::Initiatives::Permissions,
                             ::Decidim::Admin::Permissions)

        def resource
          current_initiative
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Initiatives::Admin::InitiativesPermissionsController)
        end
      end
    end
  end
end
