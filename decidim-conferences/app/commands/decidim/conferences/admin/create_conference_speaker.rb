# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new conference
      # speaker in the system.
      class CreateConferenceSpeaker < Decidim::Commands::CreateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :full_name, :twitter_handle, :personal_url, :position, :affiliation, :short_bio,
                              :user

        protected

        def create_resource(soft: nil)
          super
        rescue ActiveRecord::RecordInvalid => e
          form.errors.add(:avatar, resource.errors[:avatar]) if resource.errors.include? :avatar

          raise Decidim::Commands::HookError, e
        end

        def extra_params
          {
            resource: {
              title: form.full_name
            },
            participatory_space: {
              title: form.current_participatory_space.title
            }
          }
        end

        def attributes
          super.merge(conference: form.current_participatory_space).merge(attachment_attributes(:avatar))
        end

        def conference_meetings(speaker)
          meeting_components = speaker.conference.components.where(manifest_name: "meetings")
          Decidim::ConferenceMeeting.where(component: meeting_components).where(id: @form.attributes[:conference_meeting_ids])
        end

        def run_after_hooks
          resource.conference_meetings = conference_meetings(resource)
        end
      end
    end
  end
end
