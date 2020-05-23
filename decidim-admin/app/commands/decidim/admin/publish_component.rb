# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a component is published from the admin panel.
    class PublishComponent < Rectify::Command
      # Public: Initializes the command.
      #
      # component - The component to publish.
      # current_user - the user performing the action
      def initialize(component, current_user)
        @component = component
        @current_user = current_user
      end

      # Public: Publishes the Component.
      #
      # Broadcasts :ok if published, :invalid otherwise.
      def call
        publish_component
        publish_event

        broadcast(:ok)
      end

      private

      attr_reader :component, :current_user

      def publish_component
        Decidim.traceability.perform_action!(
          :publish,
          component,
          current_user,
          visibility: "all"
        ) do
          component.publish!
          component
        end
      end

      def publish_event
        return if component.parent

        Decidim::EventsManager.publish(
          event: "decidim.events.components.component_published",
          event_class: Decidim::ComponentPublishedEvent,
          resource: component,
          followers: component.participatory_space.followers
        )
      end
    end
  end
end
