# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic when creating a new participatory
    # process in the system.
    class CreateParticipatoryProcessStep < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_process - The ParticipatoryProcess that will hold the
      #   step
      def initialize(form, participatory_process)
        @form = form
        @participatory_process = participatory_process
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_participatory_process_step
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_participatory_process_step
        ParticipatoryProcessStep.create!(
          title: form.title,
          description: form.description,
          short_description: form.short_description,
          start_date: form.start_date,
          end_date: form.end_date,
          participatory_process: @participatory_process
        )
      end
    end
  end
end
