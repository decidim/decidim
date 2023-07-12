# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process user roles.
      #
      class ParticipatoryProcessUserRolesController < Decidim::Admin::ParticipatorySpace::UserRoleController
        include Concerns::ParticipatoryProcessAdmin

        def authorization_scope = :process_user_role

        def resource_form = form(ParticipatoryProcessUserRoleForm)

        def space_index_path = participatory_process_user_roles_path(current_participatory_space)

        def i18n_scope = "decidim.admin.participatory_process_user_roles"

        def role_class = Decidim::ParticipatoryProcessUserRole

        def event = "decidim.events.participatory_process.role_assigned"

        def event_class = Decidim::ParticipatoryProcessRoleAssignedEvent
      end
    end
  end
end
