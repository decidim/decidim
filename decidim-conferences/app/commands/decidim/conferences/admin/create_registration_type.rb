# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new registration type
      # in the system.
      class CreateRegistrationType < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :description, :price, :weight

        protected

        def resource_class = Decidim::Conferences::RegistrationType

        def extra_params
          {
            resource: {
              title: form.title
            },
            participatory_space: {
              title: form.current_participatory_space.title
            }
          }
        end

        def attributes
          super.merge({ conference: form.current_participatory_space })
        end

        def conference_meetings(registration_type)
          meeting_components = registration_type.conference.components.where(manifest_name: "meetings")
          Decidim::ConferenceMeeting.where(component: meeting_components).where(id: @form.attributes[:conference_meeting_ids])
        end

        def run_after_hooks
          resource.conference_meetings = conference_meetings(resource)
        end
      end
    end
  end
end
