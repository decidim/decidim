# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to update an attachment from a
    # participatory process.
    class UpdateAttachment < Rectify::Command
      attr_reader :attachment

      # Public: Initializes the command.
      #
      # attachment - the Attachment to update
      # form - A form object with the params.
      def initialize(attachment, form)
        @attachment = attachment
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

        update_attachment
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_attachment
        attachment.update_attributes!(attributes)
      end

      def attributes
        {
          title: form.title,
          file: form.file,
          description: form.description
        }.reject do |_attribute, value|
          value.blank?
        end
      end
    end
  end
end
