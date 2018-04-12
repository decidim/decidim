# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Minute from the admin
      # panel.
      class UpdateMinute < Rectify::Command
        # Initializes a UpdateMinute Command.
        #
        # form - The form from which to get the data.
        # current_meeting - The current instance of the meeting.
        # minute - The current instance of the minute to be updated.
        def initialize(form, current_meeting, minute)
          @form = form
          @current_meeting = current_meeting
          @minute = minute
        end

        # Updates the minute if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?
          transaction do
            update_minute!
          end

          broadcast(:ok, minute)
        end

        private

        attr_reader :form, :current_meeting, :minute

        def update_minute!
          log_info = {
            resource: {
              title: @current_meeting.title
            },
            participatory_space: {
              title: @current_meeting.participatory_space.title
            }
          }

          @minute = Decidim.traceability.update!(
            minute,
            form.current_user,
            {
              description: form.description,
              video_url: form.video_url,
              audio_url: form.audio_url,
              is_visible: form.is_visible,
              meeting: current_meeting
            },
            log_info
          )
        end
      end
    end
  end
end
