# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # speaker in the system.
      class UpdateConferenceSpeaker < Decidim::Commands::UpdateResource
        fetch_file_attributes :avatar

        fetch_form_attributes :full_name, :twitter_handle, :personal_url, :position, :affiliation, :user, :short_bio

        protected

        def invalid?
          form.invalid? || !resource
        end

        def extra_params
          {
            resource: {
              title: resource.full_name
            },
            participatory_space: {
              title: resource.conference.title
            }
          }
        end

        private

        def conference_meetings
          meeting_components = resource.conference.components.where(manifest_name: "meetings")
          Decidim::ConferenceMeeting.where(component: meeting_components).where(id: form.conference_meeting_ids)
        end

        def run_after_hooks
          resource.conference_meetings = conference_meetings
        end
      end
    end
  end
end
