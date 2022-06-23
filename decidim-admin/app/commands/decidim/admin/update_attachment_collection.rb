# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating an attachment collection.
    class UpdateAttachmentCollection < Decidim::Command
      # Public: Initializes the command.
      #
      # attachment_collection - The AttachmentCollection to update
      # form - A form object with the params.
      def initialize(attachment_collection, form, user)
        @attachment_collection = attachment_collection
        @form = form
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_attachment_collection
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_attachment_collection
        Decidim.traceability.update!(
          @attachment_collection,
          @user,
          attributes
        )
      end

      def attributes
        {
          name: form.name,
          weight: form.weight,
          description: form.description
        }
      end
    end
  end
end
