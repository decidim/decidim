# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # speaker in the system.
      class UpdateConferenceSpeaker < Decidim::Commands::UpdateResource
        include ::Decidim::AttachmentAttributesMethods

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

        def update_resource
          super
        rescue ActiveRecord::RecordInvalid => e
          form.errors.add(:avatar, resource.errors[:avatar]) if resource.errors.include? :avatar

          raise Decidim::Commands::HookError, e
        end

        private

        def attributes
          super.merge(attachment_attributes(:avatar))
        end

        def conference_meetings(speaker)
          meeting_components = speaker.conference.components.where(manifest_name: "meetings")
          Decidim::ConferenceMeeting.where(component: meeting_components).where(id: form.attributes[:conference_meeting_ids])
        end

        def run_after_hooks
          resource.conference_meetings = conference_meetings(resource)
        end
      end
    end
  end
end
