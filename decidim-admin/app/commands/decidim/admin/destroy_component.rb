# frozen_string_literal: true
module Decidim
  module Admin
    # This command deals with destroying a Component from the admin panel.
    class DestroyComponent < Rectify::Command
      # Public: Initializes the command.
      #
      # component - The Component to be destroyed.
      def initialize(component)
        @component = component
      end

      # Public: Executes the command.
      #
      # Broadcasts :ok if it got destroyed.
      def call
        transaction do
          destroy_component
          run_hooks
        end

        broadcast(:ok)
      end

      private

      def destroy_component
        @component.destroy!
      end

      def run_hooks
        @component.manifest.run_hooks(:destroy, @component)
      end
    end
  end
end
