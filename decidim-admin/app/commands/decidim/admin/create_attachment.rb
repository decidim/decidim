# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to add an attachment to a
    # participatory process.
    class CreateAttachment < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # attached_to - The ActiveRecord::Base that will hold the attachment
      def initialize(form, attached_to)
        @form = form
        @attached_to = attached_to
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        build_attachment

        if @attachment.valid?
          @attachment.save!
          broadcast(:ok)
        else
          if @attachment.errors.has_key? :file
            @form.errors.add :file, @attachment.errors[:file]
          end
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form

      def build_attachment
        @attachment = Attachment.new(
          title: form.title,
          description: form.description,
          file: form.file,
          attached_to: @attached_to
        )
      end
    end
  end
end
