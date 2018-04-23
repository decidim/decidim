# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the Assembly' Component
      # permissions in the admin panel.
      #
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include Concerns::AssemblyAdmin

        def current_participatory_space_manifest_name
          :assemblies
        end
      end
    end
  end
end
