# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user leaves a meeting.
    class LeaveMeeting < Decidim::Command
      # Initializes a LeaveMeeting Command.
      #
      # meeting - The current instance of the meeting to be left.
      # user - The user leaving the meeting.
      def initialize(meeting, user)
        @meeting = meeting
        @user = user
      end

      # Destroys a meeting registration if the meeting has registrations enabled
      # and the registration exists.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless registration

        @meeting.with_lock do
          destroy_registration
          destroy_questionnaire_responses
          decrement_score
          promote_from_waitlist!
        end
        broadcast(:ok)
      end

      private

      def registration
        @registration ||= Decidim::Meetings::Registration.find_by(meeting: @meeting, user: @user)
      end

      def destroy_registration
        registration.destroy!
      end

      def questionnaire_responses
        questionnaire = Decidim::Forms::Questionnaire.find_by(questionnaire_for_id: @meeting)
        questionnaire.responses.where(user: @user) if questionnaire.present?
      end

      def destroy_questionnaire_responses
        questionnaire_responses.try(:destroy_all)
      end

      def decrement_score
        Decidim::Gamification.decrement_score(@user, :attended_meetings)
      end

      def promote_from_waitlist!
        return if @meeting.available_slots.zero?
        return unless @meeting.remaining_slots.positive?
        return unless @meeting.registrations.on_waiting_list.exists?

        Decidim::Meetings::PromoteFromWaitlistJob.perform_later(@meeting.id)
      end
    end
  end
end
