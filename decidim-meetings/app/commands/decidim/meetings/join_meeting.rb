# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user joins a meeting.
    class JoinMeeting < Rectify::Command
      # Initializes a JoinMeeting Command.
      #
      # meeting - The current instance of the meeting to be joined.
      # user - The user joining the meeting.
      def initialize(meeting, user, registration_form)
        @meeting = meeting
        @user = user
        @registration_form = registration_form
      end

      # Creates a meeting registration if the meeting has registrations enabled
      # and there are available slots.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        meeting.with_lock do
          return broadcast(:invalid) unless can_join_meeting?

          if registration_form
            return broadcast(:invalid) unless registration_form.valid?
            answer_registration_form
          end

          create_registration
          send_email_confirmation
          send_notification
        end
        broadcast(:ok)
      end

      private

      attr_reader :meeting, :user, :registration_form

      def answer_registration_form
        registration_form.answers.each do |form_answer|
          answer = QuestionnaireAnswer.new(
            user: user,
            questionnaire: meeting.registration_form,
            question: form_answer.question,
            body: form_answer.body
          )

          form_answer.selected_choices.each do |choice|
            answer.choices.build(
              body: choice.body,
              custom_body: choice.custom_body,
              decidim_meetings_questionnaire_answer_option_id: choice.answer_option_id,
              position: choice.position
            )
          end

          answer.save!
        end
      end

      def create_registration
        Decidim::Meetings::Registration.create!(meeting: meeting, user: user)
      end

      def can_join_meeting?
        meeting.registrations_enabled? && meeting.has_available_slots?
      end

      def send_email_confirmation
        Decidim::Meetings::RegistrationMailer.confirmation(user, meeting).deliver_later
      end

      def participatory_space_admins
        @meeting.component.participatory_space.admins
      end

      def send_notification
        return send_notification_over(0.5) if occupied_slots_over?(0.5)
        return send_notification_over(0.8) if occupied_slots_over?(0.8)
        send_notification_over(1.0) if occupied_slots_over?(1.0)
      end

      def send_notification_over(percentage)
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_registrations_over_percentage",
          event_class: Decidim::Meetings::MeetingRegistrationsOverPercentageEvent,
          resource: @meeting,
          recipient_ids: participatory_space_admins.pluck(:id),
          extra: {
            percentage: percentage
          }
        )
      end

      def occupied_slots_over?(percentage)
        @meeting.remaining_slots == (@meeting.available_slots * (1 - percentage)).round
      end
    end
  end
end
