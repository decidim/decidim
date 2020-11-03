# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meetings from a Participatory Process
      class MeetingClosesController < Admin::ApplicationController
        include Decidim::Proposals::Admin::Picker

        helper_method :meeting

        def edit
          enforce_permission_to :close, :meeting, meeting: meeting

          @form = form(Admin::CloseMeetingForm).from_model(meeting)
        end

        def update
          enforce_permission_to :close, :meeting, meeting: meeting

          @form = form(Admin::CloseMeetingForm).from_params(params.merge(proposals: meeting.sibling_scope(:proposals)))

          CloseMeeting.call(@form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("meetings.close.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meetings.close.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        private

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:id])
        end
      end
    end
  end
end
