# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to deactivate a participatory space.
    class DeactivateParticipatorySpace < Rectify::Command
      # Public: Initializes the command.
      #
      # participatory_space - The participatory space to activate
      # current_user - the user performing the action
      def initialize(participatory_space, current_user)
        @participatory_space = participatory_space
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        broadcast(:invalid) unless participatory_space.active?
        deactivate_participatory_space
        broadcast(:ok)
      end

      private

      attr_reader :current_user

      def deactivate_participatory_space
        Decidim.traceability.perform_action!(
          "deactivate",
          @participatory_space,
          current_user,
          manifest_name: @participatory_space.manifest_name
        ) do
          @participatory_space.deactivate!
        end
      end
    end
  end
end
