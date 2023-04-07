# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new conference
      # admin in the system.
      class CreateConferenceAdmin < Decidim::Admin::ParticipatorySpace::CreateAdmin
        private

        attr_reader :form, :participatory_space, :current_user, :user

        def event = "decidim.events.conferences.role_assigned"

        def event_class = Decidim::Conferences::ConferenceRoleAssignedEvent

        def existing_role
          Decidim::ConferenceUserRole.exists?(
            role: form.role.to_sym,
            user:,
            conference: participatory_space
          )
        end

        def create_role
          extra_info = {
            resource: {
              title: user.name
            }
          }
          role_params = {
            role: form.role.to_sym,
            user:,
            conference: participatory_space
          }

          Decidim.traceability.create!(Decidim::ConferenceUserRole, current_user, role_params, extra_info)

          send_notification user
        end
      end
    end
  end
end
