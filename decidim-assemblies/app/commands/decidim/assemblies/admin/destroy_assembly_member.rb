# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when destroying an assembly
      # member in the system.
      class DestroyAssemblyMember < Decidim::Commands::DestroyResource
        private

        def extra_params
          {
            resource: {
              title: resource.full_name
            },
            participatory_space: {
              title: resource.assembly.title
            }
          }
        end
      end
    end
  end
end
