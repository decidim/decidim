# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a TimelineEntry
      # for a Result from the admin panel.
      class CreateTimelineEntry < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Creates the timeline_entry if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_timeline_entry
          end

          broadcast(:ok)
        end

        private

        attr_reader :timeline_entry, :form

        def create_timeline_entry
          @timeline_entry = TimelineEntry.create!(
            decidim_accountability_result_id: form.decidim_accountability_result_id,
            entry_date: form.entry_date,
            title: form.title,
            description: form.description
          )
        end
      end
    end
  end
end
