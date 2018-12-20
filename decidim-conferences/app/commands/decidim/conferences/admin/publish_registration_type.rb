# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This command gets called when a registration_type is published from the admin panel.
      class PublishRegistrationType < Rectify::Command
        # Public: Initializes the command.
        #
        # registration_type - The registration_type to publish.
        # current_user - the user performing the action
        def initialize(registration_type, current_user)
          @registration_type = registration_type
          @current_user = current_user
        end

        # Public: Publishes the Component.
        #
        # Broadcasts :ok if published, :invalid otherwise.
        def call
          return broadcast(:invalid) if registration_type.nil? || registration_type.published?

          Decidim.traceability.perform_action!(:publish, registration_type, current_user) do
            registration_type.publish!
          end

          broadcast(:ok)
        end

        private

        attr_reader :registration_type, :current_user
      end
    end
  end
end
