# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying a Component from the admin panel.
    class DestroyComponent < Rectify::Command
      # Public: Initializes the command.
      #
      # component - The Component to be destroyed.
      # current_user - the user performing the action
      def initialize(component, current_user)
        @component = component
        @current_user = current_user
      end

      # Public: Executes the command.
      #
      # Broadcasts :ok if it got destroyed, raises an exception otherwise.
      def call
        begin
          destroy_component
        rescue StandardError
          return broadcast(:invalid)
        end
        broadcast(:ok)
      end

      private

      def destroy_component
        transaction do
          run_before_hooks

          Decidim.traceability.perform_action!(
            "delete",
            @component,
            @current_user
          ) do
            @component.destroy!
          end

          run_hooks
        end
      end

      def run_before_hooks
        @component.manifest.run_hooks(:before_destroy, @component)
      end

      def run_hooks
        @component.manifest.run_hooks(:destroy, @component)
      end
    end
  end
end
