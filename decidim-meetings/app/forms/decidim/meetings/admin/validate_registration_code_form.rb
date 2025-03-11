# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to validate registration codes from Decidim's admin panel.
      class ValidateRegistrationCodeForm < Decidim::Form
        attribute :code, String

        validates :code, presence: true
        validate :registration_exists

        def registration
          @registration ||= meeting.registrations.find_by(code:, validated_at: nil)
        end

        private

        def meeting
          @meeting ||= context[:meeting]
        end

        def registration_exists
          return unless registration.nil?

          errors.add(
            :code,
            I18n.t("registrations_attendees.validate_registration_code.invalid", scope: "decidim.meetings.admin")
          )
        end
      end
    end
  end
end
