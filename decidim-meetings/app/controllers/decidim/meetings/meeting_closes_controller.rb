# frozen_string_literal: true

module Decidim
  module Meetings
    # This controller allows a participant to update the closing_report and the linked proposals of a closed meeting
    class MeetingClosesController < Decidim::Meetings::ApplicationController
      include Decidim::Proposals::Admin::Picker
      include FormFactory

      helper_method :meeting

      def edit
        enforce_permission_to :close, :meeting, meeting: meeting

        @form = form(CloseMeetingForm).from_model(meeting)
      end

      def update
        enforce_permission_to :close, :meeting, meeting: meeting

        @form = form(CloseMeetingForm).from_params(params.merge(proposals: meeting.sibling_scope(:proposals)))

        CloseMeeting.call(@form, meeting) do
          on(:ok) do
            flash[:notice] = I18n.t("meetings.close.success", scope: "decidim.meetings.admin")
            redirect_to meeting_path(meeting)
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
