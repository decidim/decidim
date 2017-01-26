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

          build_meeting
          return broadcast(:invalid) unless geocode_meeting
          create_meeting

          broadcast(:ok)
        end

        private

        def build_meeting
          @meeting = Meeting.build(
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
        end

        def geocode_meeting
          result = @meeting.geocode
          @form.errors.add :address, :invalid unless result
          result
        end

        def create_meeting
          @meeting.save!
        end
      end
    end
  end
end
