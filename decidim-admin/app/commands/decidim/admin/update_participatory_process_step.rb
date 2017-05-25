# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process in the system.
    class UpdateParticipatoryProcessStep < Rectify::Command
      attr_reader :participatory_process_step
      # Public: Initializes the command.
      #
      # participatory_process_step - the ParticipatoryProcessStep to update
      # form - A form object with the params.
      def initialize(participatory_process_step, form)
        @participatory_process_step = participatory_process_step
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_participatory_process_step
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_participatory_process_step
        participatory_process_step.update_attributes!(attributes)
      end

      def attributes
        {
          title: form.title,
          start_date: form.start_date,
          end_date: form.end_date,
          description: form.description
        }
      end
    end
  end
end
