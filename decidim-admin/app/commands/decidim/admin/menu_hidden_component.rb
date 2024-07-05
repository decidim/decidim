# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a component is menu_hidden from the admin panel.
    class MenuHiddenComponent < Decidim::Command
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
        component.update!(visible: false)

        broadcast(:ok)
      end

      private

      attr_reader :component, :current_user
    end
  end
end
