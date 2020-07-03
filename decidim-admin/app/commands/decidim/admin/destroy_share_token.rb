# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a share token.
    class DestroyShareToken < Rectify::Command
      # Public: Initializes the command.
      #
      # share_token - The share_token to destroy
      # current_user - the user performing the action
      def initialize(share_token, current_user)
        @share_token = share_token
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        begin
          destroy_share_token
        rescue StandardError
          broadcast(:invalid)
        end
        broadcast(:ok)
      end

      private

      attr_reader :current_user

      def destroy_share_token
        Decidim.traceability.perform_action!(
          "delete",
          @share_token,
          current_user
        ) do
          @share_token.destroy!
        end
      end
    end
  end
end
