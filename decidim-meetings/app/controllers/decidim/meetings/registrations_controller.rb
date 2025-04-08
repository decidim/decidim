# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the registration resource so users can join and leave meetings.
    class RegistrationsController < Decidim::Meetings::ApplicationController
      include Decidim::Forms::Concerns::HasQuestionnaire

      def respond
        enforce_permission_to(:join, :meeting, meeting:)

        @form = form(Decidim::Forms::QuestionnaireForm).from_params(params, session_token:)

        command = should_join_waitlist? ? JoinWaitlist : JoinMeeting
        joining_waitlist = should_join_waitlist?

        command.call(meeting, @form) do
          on(:ok) do
            flash[:notice] = I18n.t(joining_waitlist ? "registrations.waitlist.success" : "registrations.create.success", scope: "decidim.meetings")
            redirect_to after_response_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t(joining_waitlist ? "registrations.waitlist.invalid" : "registrations.create.invalid", scope: "decidim.meetings")
            render template: "decidim/forms/questionnaires/show"
          end

          on(:invalid_form) do
            flash.now[:alert] = I18n.t("response.invalid", scope: i18n_flashes_scope)
            render template: "decidim/forms/questionnaires/show"
          end
        end
      end

      def create
        enforce_permission_to(:register, :meeting, meeting:)

        @form = JoinMeetingForm.from_params(params).with_context(current_user:)

        JoinMeeting.call(meeting, @form) do
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

      def join_waitlist
        enforce_permission_to(:join_waitlist, :meeting, meeting:)

        @form = JoinMeetingForm.from_params(params).with_context(current_user:)

        JoinWaitlist.call(meeting, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("registrations.waitlist.success", scope: "decidim.meetings")
            redirect_after_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("registrations.waitlist.invalid", scope: "decidim.meetings")
            redirect_after_path
          end
        end
      end

      def destroy
        enforce_permission_to(:leave, :meeting, meeting:)

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

      def decline_invitation
        enforce_permission_to(:decline_invitation, :meeting, meeting:)

        DeclineInvitation.call(meeting, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("registrations.decline_invitation.success", scope: "decidim.meetings")
            redirect_after_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("registrations.decline_invitation.invalid", scope: "decidim.meetings")
            redirect_after_path
          end
        end
      end

      def should_join_waitlist?
        meeting.waitlist_enabled? && !meeting.has_available_slots? && !meeting.has_registration_for?(current_user)
      end

      def allow_responses?
        return false unless meeting.registrations_enabled? && meeting.registration_form_enabled?

        meeting.has_available_slots? || should_join_waitlist?
      end

      def after_response_path
        meeting_path(meeting)
      end

      # You can implement this method in your controller to change the URL
      # where the questionnaire will be submitted.
      def update_url
        respond_meeting_registration_path(meeting_id: meeting.id)
      end

      def questionnaire_for
        meeting
      end

      private

      def meeting
        @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
      end

      def redirect_after_path
        redirect_to meeting_path(meeting)
      end

      def user_has_no_permission_path
        return meeting_path(meeting) if user_signed_in?

        decidim.new_user_session_path
      end
    end
  end
end
