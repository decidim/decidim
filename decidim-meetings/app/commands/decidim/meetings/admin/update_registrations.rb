# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user updates the meeting registrations.
      class UpdateRegistrations < Rectify::Command
        # Initializes a UpdateRegistrations Command.
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
            update_meeting_registrations
          end

          broadcast(:ok)
        end

        private

        def update_meeting_registrations
          @meeting.registrations_enabled = @form.registrations_enabled

          if @form.registrations_enabled
            @meeting.available_slots = @form.available_slots
            @meeting.registration_terms = @form.registration_terms
          end

          @meeting.save!
        end
      end
    end
  end
end
