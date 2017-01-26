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
          @previous_address = meeting.address
        end

        # Updates the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          change_meeting
          if address_changed?
            return broadcast(:invalid) unless geocode_meeting
          end
          update_meeting

          broadcast(:ok)
        end

        private

        def change_meeting
           @meeting.assign_attributes(
            scope: @form.scope,
            category: @form.category,
            title: @form.title,
            short_description: @form.short_description,
            description: @form.description,
            end_time: @form.end_time,
            start_time: @form.start_time,
            address: @form.address,
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

        def address_changed?
          @form.address != @previous_address
        end
      end
    end
  end
end
