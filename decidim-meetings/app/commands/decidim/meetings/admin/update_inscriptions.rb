# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user updates the meeting inscriptions.
      class UpdateInscriptions < Rectify::Command
        # Initializes a UpdateInscriptions Command.
        #
        # form - The form from which to get the data.
        # meeting - The current instance of the meeting to be updated.
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        # Updates the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          @meeting.with_lock do
            return broadcast(:invalid) if @form.invalid?
            update_meeting_inscriptions
          end

          broadcast(:ok)
        end

        private

        def update_meeting_inscriptions
          @meeting.inscriptions_enabled = @form.inscriptions_enabled

          if @form.inscriptions_enabled
            @meeting.available_slots = @form.available_slots
            @meeting.inscription_terms = @form.inscription_terms
          end

          @meeting.save!
        end
      end
    end
  end
end
