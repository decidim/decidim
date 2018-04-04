# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that unpublishes an
      # existing initiative.
      class UnpublishInitiative < Rectify::Command
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
          return broadcast(:invalid) unless initiative.published?

          @initiative = Decidim.traceability.perform_action!(
            :unpublish,
            initiative,
            current_user
          ) do
            initiative.unpublish!
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
