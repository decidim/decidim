# frozen_string_literal: true

module Decidim
  module Votings
    # A command with all the business logic when signing a closure of a polling station
    class CertifyPollingStationClosure < Decidim::Command
      include ::Decidim::AttachmentMethods
      include ::Decidim::GalleryMethods
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # closure - A closure object.
      def initialize(form, closure)
        @form = form
        @closure = closure
        @attached_to = closure
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if process_gallery?
          build_gallery
          return broadcast(:invalid) if gallery_invalid?
        end

        transaction do
          create_gallery if process_gallery?
          closure.update!(phase: :signature)
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :closure, :attachment
    end
  end
end
