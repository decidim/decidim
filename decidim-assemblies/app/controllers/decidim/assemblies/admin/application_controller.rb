# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # The main admin application controller for assemblies
      class ApplicationController < Decidim::Admin::ApplicationController
        private

        def permissions_context
          super.merge(
            current_participatory_space: try(:current_participatory_space)
          )
        end

        def permission_class_chain
          [
            Decidim::Assemblies::Permissions,
            Decidim::Admin::Permissions
          ]
        end
      end
    end
  end
end
