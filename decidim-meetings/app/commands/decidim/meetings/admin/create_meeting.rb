# frozen_string_literal: true
module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Meeting from the admin
      # panel.
      class CreateMeeting < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          create_meeting
          broadcast(:ok)
        end

        private

        def create_meeting
          @meeting = Meeting.create!(
            scope: @form.scope,
            category: @form.category,
            title: @form.title,
            short_description: @form.short_description,
            description: @form.description,
            end_time: @form.end_time,
            start_time: @form.start_time,
            address: @form.address,
            location: @form.location,
            location_hints: @form.location_hints,
            feature: @form.current_feature
          )
          @meeting.geocode
          @meeting.save!
        end
      end
    end
  end
end
