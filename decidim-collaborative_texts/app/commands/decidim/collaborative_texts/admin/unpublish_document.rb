# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user unpublishes an
      # existing collaborative text document.
      class UnpublishDocument < Decidim::Command
        # Public: Initializes the command.
        #
        # document - Decidim::CollaborativeTexts::Document
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
          return broadcast(:invalid) unless document.published?

          @document = Decidim.traceability.perform_action!(
            :unpublish,
            document,
            current_user
          ) do
            document.unpublish!
            document
          end
          broadcast(:ok, document)
        end

        private

        attr_reader :document, :current_user
      end
    end
  end
end
