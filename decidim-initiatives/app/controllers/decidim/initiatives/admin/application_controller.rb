# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # The main admin application controller for initiatives
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/initiatives"

        def permissions_context
          super.merge(
            current_participatory_space: try(:current_participatory_space)
          )
        end

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
