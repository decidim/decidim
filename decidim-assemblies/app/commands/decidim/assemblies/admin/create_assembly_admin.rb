# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateAssemblyAdmin < Decidim::Admin::ParticipatorySpace::CreateAdmin
        private

        attr_reader :form, :participatory_space, :current_user, :user

        def event = "decidim.events.assembly.role_assigned"

        def event_class = Decidim::RoleAssignedToAssemblyEvent

        def role_class = Decidim::AssemblyUserRole

        def role_params = super.merge(assembly: participatory_space)
      end
    end
  end
end
