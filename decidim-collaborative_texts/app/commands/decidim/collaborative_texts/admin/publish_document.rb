# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user publishes an
      # existing collaborative text.
      class PublishDocument < Decidim::Command
        # Public: Initializes the command.
        #
        # collaborative text - Decidim::CollaborativeTexts::Document
        # current_user - the user performing the action
        def initialize(document, current_user)
          @document = document
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if document.published?

          transaction do
            publish_document
          end

          broadcast(:ok, document)
        end

        private

        attr_reader :document, :current_user

        def publish_document
          @collaborative_text = Decidim.traceability.perform_action!(
            :publish,
            document,
            current_user,
            visibility: "all"
          ) do
            document.publish!
            document
          end
        end
      end
    end
  end
end
