# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateParticipatoryProcessAdmin < Decidim::Admin::ParticipatorySpace::CreateAdmin
        private

        attr_reader :form, :participatory_space, :current_user, :user

        def event = "decidim.events.participatory_process.role_assigned"

        def event_class = Decidim::ParticipatoryProcessRoleAssignedEvent

        def role_class = Decidim::ParticipatoryProcessUserRole

        def role_params = super.merge(participatory_process: participatory_space)
      end
    end
  end
end
