# frozen_string_literal: true
module Decidim
  module Admin
    # A command with all the business logic to add an attachment to a
    # participatory process.
    class CreateParticipatoryProcessAttachment < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_process - The ParticipatoryProcess that will hold the
      #   attachment
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

        create_attachment
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_attachment
        ParticipatoryProcessAttachment.create!(
          title: form.title,
          description: form.description,
          file: form.file,
          participatory_process: @participatory_process
        )
      end
    end
  end
end
