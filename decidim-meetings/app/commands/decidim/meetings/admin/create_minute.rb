# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Minute from the admin
      # panel.
      class CreateMinute < Rectify::Command
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
            create_minute!
          end

          broadcast(:ok, @minute)
        end

        private

        def create_minute!
          @minute = Decidim.traceability.create!(
            Minute,
            @form.current_user,
            description: @form.description,
            video_url: @form.video_url,
            audio_url: @form.audio_url,
            is_visible: @form.is_visible,
            meeting: @meeting
          )
        end
      end
    end
  end
end
