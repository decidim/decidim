# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updated a participatory
      # process admin in the system.
      class UpdateConferenceAdmin < Decidim::Admin::ParticipatorySpace::UpdateAdmin
        def event = "decidim.events.conferences.role_assigned"

        def event_class = Decidim::Conferences::ConferenceRoleAssignedEvent
      end
    end
  end
end
