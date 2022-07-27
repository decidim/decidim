# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new registration type
      # in the system.
      class CreateRegistrationType < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # current_user - The current user hwo do the action of create
        # conference - The Conference that will hold the speaker
        def initialize(form, current_user, conference)
          @form = form
          @current_user = current_user
          @conference = conference
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_registration_type!
            link_meetings(@registration_type)
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :conference, :current_user

        def create_registration_type!
          log_info = {
            resource: {
              title: form.title
            },
            participatory_space: {
              title: conference.title
            }
          }

          @registration_type = Decidim.traceability.create!(
            Decidim::Conferences::RegistrationType,
            form.current_user,
            form.attributes.slice(
              "title",
              "description",
              "price",
              "weight"
            ).symbolize_keys.merge(
              conference:
            ),
            log_info
          )
        end

        def conference_meetings(registration_type)
          meeting_components = registration_type.conference.components.where(manifest_name: "meetings")
          Decidim::ConferenceMeeting.where(component: meeting_components).where(id: @form.attributes[:conference_meeting_ids])
        end

        def link_meetings(registration_type)
          registration_type.conference_meetings = conference_meetings(registration_type)
        end
      end
    end
  end
end
