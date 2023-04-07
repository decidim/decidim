# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when updated a participatory
      # process admin in the system.
      class UpdateParticipatoryProcessAdmin < Decidim::Admin::ParticipatorySpace::UpdateAdmin
        def event = "decidim.events.participatory_process.role_assigned"

        def event_class = Decidim::ParticipatoryProcessRoleAssignedEvent
      end
    end
  end
end
