# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateTimelineEntry < Decidim::Command
        # Initializes an UpdateTimelineEntry Command.
        #
        # form - The form from which to get the data.
        # timeline_entry - The current instance of the timeline_entry to be updated.
        def initialize(form, timeline_entry, user)
          @form = form
          @timeline_entry = timeline_entry
          @user = user
        end

        # Updates the timeline_entry if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_timeline_entry
          end

          broadcast(:ok)
        end

        private

        attr_reader :timeline_entry, :form

        def update_timeline_entry
          Decidim.traceability.update!(
            timeline_entry,
            @user,
            entry_date: form.entry_date,
            title: form.title,
            description: form.description
          )
        end
      end
    end
  end
end
