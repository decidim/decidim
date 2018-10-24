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
          publish_registration_type

          broadcast(:ok)
        end

        private

        attr_reader :registration_type, :current_user

        def publish_registration_type
          Decidim.traceability.perform_action!(
            :publish,
            registration_type,
            current_user,
            visibility: "all"
          ) do
            registration_type.publish!
            registration_type
          end
        end
      end
    end
  end
end
