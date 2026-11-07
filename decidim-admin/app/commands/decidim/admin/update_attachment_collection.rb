# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating an attachment collection.
    class UpdateAttachmentCollection < Decidim::Command
      delegate :current_user, to: :form

      attr_reader :attachment_collection

      # Public: Initializes the command.
      #
      # attachment_collection - The AttachmentCollection to update
      # form - A form object with the params.
      def initialize(attachment_collection, form)
        @attachment_collection = attachment_collection
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_attachment_collection
        broadcast(:ok, attachment_collection)
      end

      private

      attr_reader :form

      def update_attachment_collection
        Decidim.traceability.update!(
          @attachment_collection,
          current_user,
          attributes
        )
      end

      def attributes
        {
          name: form.name,
          weight: form.weight,
          description: form.description,
          # The admin edit form does not submit the key, so the saved one is
          # preserved when the form does not provide a new value; otherwise editing
          # a collection from the admin panel would erase the key used by the API
          # to look the collection up.
          key: form.key.presence || attachment_collection.key
        }
      end
    end
  end
end
