# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that accepts an
      # existing initiative.
      class AcceptInitiative < Decidim::Command
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
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if initiative.accepted?

          @initiative = Decidim.traceability.perform_action!(:accept, initiative, current_user) do
            initiative.accepted!
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
