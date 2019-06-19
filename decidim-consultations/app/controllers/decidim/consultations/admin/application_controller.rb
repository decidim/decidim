# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # The main admin application controller for consultations
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/consultations"

        helper Decidim::SanitizeHelper

        include NeedsPermission

        register_permissions(::Decidim::Consultations::Admin::ApplicationController,
                             Decidim::Consultations::Permissions,
                             Decidim::Admin::Permissions)

        private

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Consultations::Admin::ApplicationController)
        end

        def permission_scope
          :admin
        end
      end
    end
  end
end
