# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a component is marked as not visible (hidden) in the menu from the admin panel.
    class HideMenuComponent < Decidim::Command
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
      # Broadcasts :ok if disabled visibility, :invalid otherwise.
      def call
        Decidim.traceability.perform_action!(
          :menu_hidden,
          component,
          current_user,
          visibility: "all"
        ) do
          component.update!(visible: false)
        end

        broadcast(:ok)
      end

      private

      attr_reader :component, :current_user
    end
  end
end
