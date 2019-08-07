# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This command gets called when a registration type is unpublished from the admin panel.
      class UnpublishRegistrationType < Rectify::Command
        # Public: Initializes the command.
        #
        # registration_type - The registration_type to unpublish.
        # current_user - the user performing the action
        def initialize(registration_type, current_user)
          @registration_type = registration_type
          @current_user = current_user
        end

        # Public: Unpublishes the RegistrationType.
        #
        # Broadcasts :ok if unpublished, :invalid otherwise.
        def call
          return broadcast(:invalid) if registration_type.nil? || !registration_type.published?

          Decidim.traceability.perform_action!(:unpublish, registration_type, current_user) do
            registration_type.unpublish!
          end

          broadcast(:ok)
        end

        private

        attr_reader :registration_type, :current_user
      end
    end
  end
end
