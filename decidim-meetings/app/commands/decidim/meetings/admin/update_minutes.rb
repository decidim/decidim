# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Minutes from the admin
      # panel.
      class UpdateMinutes < Rectify::Command
        # Initializes a UpdateMinutes Command.
        #
        # form - The form from which to get the data.
        # current_meeting - The current instance of the meeting.
        # minutes - The current instance of the minutes to be updated.
        def initialize(form, current_meeting, minutes)
          @form = form
          @current_meeting = current_meeting
          @minutes = minutes
        end

        # Updates the minute if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_minutes!
          end

          broadcast(:ok, minutes)
        end

        private

        attr_reader :form, :current_meeting, :minutes

        def update_minutes!
          log_info = {
            resource: {
              title: @current_meeting.title
            },
            participatory_space: {
              title: @current_meeting.participatory_space.title
            }
          }

          @minutes = Decidim.traceability.update!(
            minutes,
            form.current_user,
            {
              description: form.description,
              video_url: form.video_url,
              audio_url: form.audio_url,
              visible: form.visible,
              meeting: current_meeting
            },
            log_info
          )
        end
      end
    end
  end
end
