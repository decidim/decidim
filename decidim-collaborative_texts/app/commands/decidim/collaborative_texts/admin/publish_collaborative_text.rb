# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user publishes an
      # existing collaborative text.
      class PublishCollaborativeText < Decidim::Command
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
        # - :invalid if the form wasn't valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if collaborative_text.published?

          transaction do
            publish_collaborative_text
          end

          broadcast(:ok, collaborative_text)
        end

        private

        attr_reader :collaborative_text, :current_user

        def publish_collaborative_text
          @collaborative_text = Decidim.traceability.perform_action!(
            :publish,
            collaborative_text,
            current_user,
            visibility: "all"
          ) do
            collaborative_text.publish!
            collaborative_text
          end
        end
      end
    end
  end
end
