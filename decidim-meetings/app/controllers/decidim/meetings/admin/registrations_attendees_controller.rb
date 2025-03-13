# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meeting registrations and
      # attendances from a participatory space
      class RegistrationsAttendeesController < Admin::ApplicationController
        helper_method :registrations

        def index
          enforce_permission_to(:update, :meeting, meeting:)

          @validation_form = ValidateRegistrationCodeForm.new
        end

        def validate_registration_code
          enforce_permission_to(:validate_registration_code, :meeting, meeting:)

          @validation_form = ValidateRegistrationCodeForm.from_params(params).with_context(current_organization: meeting.organization, meeting:)

          ValidateRegistrationCode.call(@validation_form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("registrations_attendees.validate_registration_code.success", scope: "decidim.meetings.admin")
              redirect_to action: "index"
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("registrations_attendees.validate_registration_code.invalid", scope: "decidim.meetings.admin")
              render action: "index"
            end
          end
        end

        def mark_as_attendee
          enforce_permission_to(:invite_attendee, :meeting, meeting:)

          registration = registrations.find(params[:id])

          MarkAsAttendee.call(registration) do
            on(:ok) do
              flash[:notice] = I18n.t("registrations_attendees.mark_attendee.success", scope: "decidim.meetings.admin")
              redirect_to action: "index"
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("registrations_attendees.mark_attendee.invalid", scope: "decidim.meetings.admin")
              render action: "index"
            end
          end
        end

        private

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end

        def registrations
          meeting.registrations
        end
      end
    end
  end
end
