# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # registration type in the system.
      class UpdateRegistrationType < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # registration_type - The RegistrationType to update
        def initialize(form, registration_type)
          @form = form
          @registration_type = registration_type
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless registration_type

          transaction do
            update_registration_type!
            link_meetings(@registration_type)
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :registration_type

        def update_registration_type!
          log_info = {
            resource: {
              title: registration_type.title
            },
            participatory_space: {
              title: registration_type.conference.title
            }
          }

          Decidim.traceability.update!(
            registration_type,
            form.current_user,
            form.attributes.slice(
              "title",
              "description",
              "price",
              "weight"
            ).symbolize_keys,
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
