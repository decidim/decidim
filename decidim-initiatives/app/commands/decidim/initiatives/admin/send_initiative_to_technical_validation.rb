# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that sends an
      # existing initiative to technical validation.
      class SendInitiativeToTechnicalValidation < Rectify::Command
        # Public: Initializes the command.
        #
        # initiative - Decidim::Initiative
        # current_user - the user performing the action
        def initialize(initiative, current_user)
          @initiative = initiative
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          @initiative = Decidim.traceability.perform_action!(
            :send_to_technical_validation,
            initiative,
            current_user
          ) do
            initiative.validating!
            initiative
          end
          broadcast(:ok, initiative)
        end

        private

        attr_reader :initiative, :current_user
      end
    end
  end
end
