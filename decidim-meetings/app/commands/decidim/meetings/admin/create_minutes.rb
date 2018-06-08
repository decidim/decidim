# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Minutes from the admin
      # panel.
      class CreateMinutes < Rectify::Command
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        # Creates the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_minutes!
          end

          broadcast(:ok, @minutes)
        end

        private

        def create_minutes!
          log_info = {
            resource: {
              title: @meeting.title
            },
            participatory_space: {
              title: @meeting.participatory_space.title
            }
          }

          @minutes = Decidim.traceability.create!(
            Minutes,
            @form.current_user,
            {
              description: @form.description,
              video_url: @form.video_url,
              audio_url: @form.audio_url,
              visible: @form.visible,
              meeting: @meeting
            },
            log_info
          )
        end
      end
    end
  end
end
