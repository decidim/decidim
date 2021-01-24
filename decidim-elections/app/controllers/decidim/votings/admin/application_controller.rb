# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # The main admin application controller for the voting space
      class ApplicationController < Decidim::Admin::ApplicationController
        register_permissions(::Decidim::Votings::Admin::ApplicationController,
                             Decidim::Votings::Admin::Permissions,
                             Decidim::Admin::Permissions)

        private

        def permissions_context
          super.merge(
            current_participatory_space: try(:current_participatory_space)
          )
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Votings::Admin::ApplicationController)
        end
      end
    end
  end
end
