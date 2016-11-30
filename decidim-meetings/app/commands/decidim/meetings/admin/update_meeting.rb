# frozen_string_literal: true
module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Meeting from the admin
      # panel.
      class UpdateMeeting < Rectify::Command
        # Initializes a UpdateMeeting Command.
        #
        # form - The form from which to get the data.
        # meeting - The current instance of the page to be updated.
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        # Updates the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          update_meeting
          broadcast(:ok)
        end

        private

        def update_meeting
          @meeting.update_attributes!(
            title: @form.title,
            short_description: @form.short_description,
            description: @form.description,
            end_date: @form.end_date,
            start_date: @form.start_date,
            address: @form.address,
            location_hints: @form.location_hints
          )
        end
      end
    end
  end
end
