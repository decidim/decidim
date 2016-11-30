# frozen_string_literal: true
require "decidim/admin/components/base_controller"

module Decidim
  module Meetings
    module Admin
      # This controller allows the user to update a Meeting.
      class MeetingsController < Admin::ApplicationController
        def edit
          @form = form(Admin::MeetingForm).from_model(meeting)
        end

        def update
          @form = form(Admin::MeetingForm).from_params(params)

          Admin::UpdateMeeting.call(@form, meeting) do
            on(:ok) do
              flash.now[:notice] = I18n.t("meetings.update.success", scope: "decidim.meetings.admin")
              render action: "edit"
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meetings.update.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        private

        def meeting
          @meeting ||= Meetings::Meeting.find_by(component: current_component)
        end
      end
    end
  end
end
