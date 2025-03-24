# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user joins a meeting.
    class JoinMeeting < Decidim::Command
      delegate :current_user, to: :form
      # Initializes a JoinMeeting Command.
      #
      # meeting - The current instance of the meeting to be joined.
      # form - A form object with params; can be a questionnaire.
      def initialize(meeting, form)
        @meeting = meeting
        @form = form
      end

      # Creates a meeting registration if the meeting has registrations enabled
      # and there are available slots.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless can_join_meeting?
        return broadcast(:invalid_form) unless form.valid?
        return broadcast(:invalid) if response_questionnaire == :invalid

        meeting.with_lock do
          create_registration
          accept_invitation
          send_email_confirmation
          send_notification_confirmation
          notify_admin_over_percentage
          increment_score
        end
        follow_meeting
        broadcast(:ok)
      end

      private

      attr_reader :meeting, :registration, :form

      def accept_invitation
        meeting.invites.find_by(user: current_user)&.accept!
      end

      def response_questionnaire
        return unless questionnaire?

        Decidim::Forms::ResponseQuestionnaire.call(form, meeting.questionnaire) do
          on(:ok) do
            return :valid
          end

          on(:invalid) do
            return :invalid
          end
        end
      end

      def create_registration
        @registration = Decidim::Meetings::Registration.create!(
          meeting:,
          user: current_user,
          public_participation: form.public_participation
        )
      end

      def can_join_meeting?
        meeting.registrations_enabled? && meeting.has_available_slots? &&
          !meeting.has_registration_for?(current_user)
      end

      def send_email_confirmation
        Decidim::Meetings::RegistrationMailer.confirmation(current_user, meeting, registration).deliver_later
      end

      def send_notification_confirmation
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_registration_confirmed",
          event_class: Decidim::Meetings::MeetingRegistrationNotificationEvent,
          resource: @meeting,
          affected_users: [current_user],
          extra: {
            registration_code: @registration.code
          }
        )
      end

      def participatory_space_admins
        @meeting.component.participatory_space.admins
      end

      def notify_admin_over_percentage
        return send_notification_over(0.5) if occupied_slots_over?(0.5)
        return send_notification_over(0.8) if occupied_slots_over?(0.8)

        send_notification_over(1.0) if occupied_slots_over?(1.0)
      end

      def send_notification_over(percentage)
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_registrations_over_percentage",
          event_class: Decidim::Meetings::MeetingRegistrationsOverPercentageEvent,
          resource: @meeting,
          affected_users: participatory_space_admins,
          extra: {
            percentage:
          }
        )
      end

      def increment_score
        Decidim::Gamification.increment_score(current_user, :attended_meetings)
      end

      def follow_meeting
        Decidim::CreateFollow.call(follow_form)
      end

      def follow_form
        Decidim::FollowForm
          .from_params(followable_gid: meeting.to_signed_global_id.to_s)
          .with_context(current_user:)
      end

      def occupied_slots_over?(percentage)
        @meeting.remaining_slots == (@meeting.available_slots * (1 - percentage)).round
      end

      def questionnaire?
        form.model_name == "questionnaire"
      end
    end
  end
end
