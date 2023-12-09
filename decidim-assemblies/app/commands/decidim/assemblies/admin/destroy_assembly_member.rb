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
              title: assembly_member.full_name
            },
            participatory_space: {
              title: assembly_member.assembly.title
            }
          }
        end
      end
    end
  end
end
