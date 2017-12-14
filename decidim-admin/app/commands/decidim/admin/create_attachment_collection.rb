# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to add an attachment collection
    # to a participatory space.
    class CreateAttachmentCollection < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # participatory_space - The participatory space that will hold the
      #   attachment collection
      def initialize(form, participatory_space)
        @form = form
        @participatory_space = participatory_space
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_attachment_collection
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_attachment_collection
        AttachmentCollection.create!(
          name: form.name,
          description: form.description,
          participatory_space: @participatory_space
        )
      end
    end
  end
end
