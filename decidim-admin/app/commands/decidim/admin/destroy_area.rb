# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy an area.
    class DestroyArea < Rectify::Command
      # Public: Initializes the command.
      #
      # area - The area to destroy
      # current_user - the user performing the action
      def initialize(area, current_user)
        @area = area
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        if area_has_dependencies?
          broadcast(:has_spaces)
        else
          destroy_area
          broadcast(:ok)
        end
      end

      private

      attr_reader :current_user

      def area_has_dependencies?
        Decidim.participatory_space_registry.manifests.any? do |manifest|
          manifest
            .participatory_spaces
            .call(@area.organization)
            .any? do |space|
            space.respond_to?(:area) && space.decidim_area_id == @area.id
          end
        end
      end

      def destroy_area
        Decidim.traceability.perform_action!(
          "delete",
          @area,
          current_user
        ) do
          @area.destroy!
        end
      end
    end
  end
end
