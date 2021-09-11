# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the Assembly' Component
      # permissions in the admin panel.
      #
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include Concerns::AssemblyAdmin

        protected

        def allowed_params
          super.push(:assembly_slug)
        end
      end
    end
  end
end
