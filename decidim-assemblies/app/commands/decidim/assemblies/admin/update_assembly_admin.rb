# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updated a participatory
      # process admin in the system.
      class UpdateAssemblyAdmin < Decidim::Admin::ParticipatorySpace::UpdateAdmin
        def event = "decidim.events.assembly.role_assigned"

        def event_class = Decidim::RoleAssignedToAssemblyEvent
      end
    end
  end
end
