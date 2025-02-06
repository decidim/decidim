# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user unpublishes an
      # existing collaborative text.
      class UnpublishDocument < Decidim::Command
        # Public: Initializes the command.
        #
        # collaborative text - Decidim::CollaborativeTexts::Document
        # current_user - the user performing the action
        def initialize(collaborative_text, current_user)
          @collaborative_text = collaborative_text
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless collaborative_text.published?

          @collaborative_text = Decidim.traceability.perform_action!(
            :unpublish,
            collaborative_text,
            current_user
          ) do
            collaborative_text.unpublish!
            collaborative_text
          end
          broadcast(:ok, collaborative_text)
        end

        private

        attr_reader :collaborative_text, :current_user
      end
    end
  end
end
