# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the inscription resource so users can join and leave meetings.
    class InscriptionsController < Decidim::Meetings::ApplicationController
      def create
        authorize! :join, meeting

        JoinMeeting.call(meeting, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("inscriptions.create.success", scope: "decidim.meetings")
            redirect_to meeting_path(meeting)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("inscriptions.create.invalid", scope: "decidim.meetings")
            redirect_to meeting_path(meeting)
          end
        end
      end

      def destroy
        authorize! :leave, meeting

        LeaveMeeting.call(meeting, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("inscriptions.destroy.success", scope: "decidim.meetings")
            redirect_to meeting_path(meeting)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("inscriptions.destroy.invalid", scope: "decidim.meetings")
            redirect_to meeting_path(meeting)
          end
        end
      end

      private

      def meeting
        @meeting ||= Meeting.where(feature: current_feature).find(params[:meeting_id])
      end
    end
  end
end
