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

          update_meeting!
          broadcast(:ok, @meeting)
        end

        private

        def update_meeting!
          @meeting.update_attributes!(
            scope: @form.scope,
            category: @form.category,
            title: @form.title,
            description: @form.description,
            end_time: @form.end_time,
            start_time: @form.start_time,
            address: @form.address,
            latitude: @form.latitude,
            longitude: @form.longitude,
            location: @form.location,
            location_hints: @form.location_hints
          )
        end

        def geocode_meeting
          result = @meeting.geocode
          @form.errors.add :address, :invalid unless result
          result
        end

        def update_meeting
          @meeting.save!
        end
      end
    end
  end
end
