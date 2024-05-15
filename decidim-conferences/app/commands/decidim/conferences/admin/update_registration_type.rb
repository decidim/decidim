# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # registration type in the system.
      class UpdateRegistrationType < Decidim::Commands::UpdateResource
        fetch_form_attributes :title, :description, :price, :weight

        def invalid?
          form.invalid? || !resource
        end

        def run_after_hooks
          resource.conference_meetings = conference_meetings(resource)
        end

        protected

        def extra_params
          {
            resource: {
              title: resource.title
            },
            participatory_space: {
              title: resource.conference.title
            }
          }
        end

        def conference_meetings(registration_type)
          meeting_components = registration_type.conference.components.where(manifest_name: "meetings")
          Decidim::ConferenceMeeting.where(component: meeting_components).where(id: @form.attributes[:conference_meeting_ids])
        end
      end
    end
  end
end
