# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the registration resource so users can join and leave meetings.
    class RegistrationsController < Decidim::Meetings::ApplicationController
      include FormFactory

      helper_method :meeting, :questionnaire

      def show
        enforce_permission_to :join, :meeting, meeting: meeting

        @form = form(QuestionnaireForm).from_model(questionnaire)
      end

      def answer
        enforce_permission_to :join, :meeting, meeting: meeting

        @form = form(QuestionnaireForm).from_params(params)

        JoinMeeting.call(meeting, current_user, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("registrations.create.success", scope: "decidim.meetings")
            redirect_to meeting_path(meeting)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("registrations.create.invalid", scope: "decidim.meetings")
            render :show
          end
        end
      end

      def create
        enforce_permission_to :join, :meeting, meeting: meeting

        JoinMeeting.call(meeting, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("registrations.create.success", scope: "decidim.meetings")
            redirect_after_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("registrations.create.invalid", scope: "decidim.meetings")
            redirect_after_path
          end
        end
      end

      def destroy
        enforce_permission_to :leave, :meeting, meeting: meeting

        LeaveMeeting.call(meeting, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("registrations.destroy.success", scope: "decidim.meetings")
            redirect_after_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("registrations.destroy.invalid", scope: "decidim.meetings")
            redirect_after_path
          end
        end
      end

      private

      def meeting
        @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
      end

      def questionnaire
        @questionnaire ||= meeting.registration_form
      end

      def redirect_after_path
        referer = request.headers["Referer"]
        return redirect_to(meeting_path(meeting)) if referer =~ /invitation_token/
        redirect_back fallback_location: meeting_path(meeting)
      end
    end
  end
end
