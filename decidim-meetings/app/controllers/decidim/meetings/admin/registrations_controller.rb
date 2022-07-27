# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meeting registrations from a Participatory Process
      class RegistrationsController < Admin::ApplicationController
        def edit
          enforce_permission_to :update, :meeting, meeting: meeting

          @form = MeetingRegistrationsForm.from_model(meeting)
          @validation_form = ValidateRegistrationCodeForm.new
        end

        def update
          enforce_permission_to :update, :meeting, meeting: meeting

          @form = MeetingRegistrationsForm.from_params(params).with_context(current_organization: meeting.organization, meeting:)
          @validation_form = ValidateRegistrationCodeForm.new

          UpdateRegistrations.call(@form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("registrations.update.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("registrations.update.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        def export
          enforce_permission_to :export_registrations, :meeting, meeting: meeting

          ExportMeetingRegistrations.call(meeting, params[:format], current_user) do
            on(:ok) do |export_data|
              send_data export_data.read, type: "text/#{export_data.extension}", filename: export_data.filename("registrations")
            end
          end
        end

        def validate_registration_code
          enforce_permission_to :update, :meeting, meeting: meeting

          @form = MeetingRegistrationsForm.from_model(meeting)
          @validation_form = ValidateRegistrationCodeForm.from_params(params).with_context(current_organization: meeting.organization, meeting:)

          ValidateRegistrationCode.call(@validation_form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("registrations.validate_registration_code.success", scope: "decidim.meetings.admin")
              render action: "edit"
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("registrations.validate_registration_code.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        private

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end
      end
    end
  end
end
