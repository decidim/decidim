# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meeting registrations from a Participatory Process
      class RegistrationsController < Admin::ApplicationController
        def edit
          @form = MeetingRegistrationsForm.from_model(meeting)
        end

        def update
          @form = MeetingRegistrationsForm.from_params(params).with_context(current_organization: meeting.organization, meeting: meeting)

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
          format = params[:format]
          export_data = Decidim::Exporters.find_exporter(format).new(meeting.registrations, Decidim::Meetings::RegistrationSerializer).export

          send_data export_data.read, type: "text/#{export_data.extension}", filename: export_data.filename("registrations")
        end

        private

        def meeting
          @meeting ||= Meeting.where(feature: current_feature).find(params[:meeting_id])
        end
      end
    end
  end
end
