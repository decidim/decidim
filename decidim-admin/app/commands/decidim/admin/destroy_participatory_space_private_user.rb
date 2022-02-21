# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a participatory space private user.
    class DestroyParticipatorySpacePrivateUser < Decidim::Command
      # Public: Initializes the command.
      #
      # participatory_space_private_user - The participatory space private user to destroy
      # current_user - the user performing the action
      def initialize(participatory_space_private_user, current_user)
        @participatory_space_private_user = participatory_space_private_user
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_participatory_space_private_user
        broadcast(:ok)
      end

      private

      attr_reader :current_user

      def destroy_participatory_space_private_user
        Decidim.traceability.perform_action!(
          "delete",
          @participatory_space_private_user,
          current_user,
          resource: {
            title: @participatory_space_private_user.user.name
          }
        ) do
          @participatory_space_private_user.destroy!
        end
      end
    end
  end
end
