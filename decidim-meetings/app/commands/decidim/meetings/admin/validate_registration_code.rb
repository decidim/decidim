# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the admin validates a registration code in the admin panel.
      class ValidateRegistrationCode < Rectify::Command
        # Initializes a ValidateRegistrationCode Command.
        #
        # form - The form from which to get the data.
        # meeting - The current instance of the meeting to be updated.
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        # Validates the registration code the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          if registration.blank?
            form.errors.add :code, I18n.t("registrations.validate_registration_code.invalid", scope: "decidim.meetings.admin")
            return broadcast(:invalid)
          end

          validate_registration_code
          send_notification

          broadcast(:ok)
        end

        private

        attr_reader :form, :meeting

        def validate_registration_code
          registration.validated_at = Time.current
          registration.save!
        end

        def registration
          @registration ||= meeting.registrations.find_by(code: form.code, validated_at: nil)
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.registration_code_validated",
            event_class: Decidim::Meetings::RegistrationCodeValidatedEvent,
            resource: meeting,
            recipient_ids: [registration.user.id],
            extra: {
              registration: registration
            }
          )
        end
      end
    end
  end
end
