# frozen_string_literal: true
module Decidim
  module Results
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateResult < Rectify::Command
        # Initializes a UpdateResult Command.
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
            scope: @form.scope,
            category: @form.category,
            title: @form.title,
            short_description: @form.short_description,
            description: @form.description
          )
        end
      end
    end
  end
end
