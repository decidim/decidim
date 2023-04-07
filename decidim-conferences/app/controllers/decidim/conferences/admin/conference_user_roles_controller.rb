# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference user roles.
      #
      class ConferenceUserRolesController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::Admin::ParticipatorySpace::UserRoleController

        def authorization_scope = :conference_user_role

        def resource_form = form(ConferenceUserRoleForm)

        def space_index_path = conference_user_roles_path(current_participatory_space)

        def i18n_scope = "decidim.admin.conference_user_roles"

        def create_command = Decidim::Conferences::Admin::CreateConferenceAdmin

        def role_class = Decidim::ConferenceUserRole

        def event = "decidim.events.conferences.role_assigned"

        def event_class = Decidim::Conferences::ConferenceRoleAssignedEvent
      end
    end
  end
end
