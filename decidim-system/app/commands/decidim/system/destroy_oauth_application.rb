# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying an application from the admin panel.
    class DestroyOAuthApplication < Rectify::Command
      # Public: Initializes the command.
      #
      # application - The OAuthApplication to be destroyed.
      # user        - The user that destroys the application.
      def initialize(application, current_user)
        @application = application
        @current_user = current_user
      end

      # Public: Executes the command.
      #
      # Broadcasts :ok if it got destroyed
      def call
        destroy_application
        broadcast(:ok)
      end

      private

      attr_reader :application, :current_user

      def destroy_application
        Decidim.traceability.perform_action!(
          "delete",
          application,
          current_user
        ) do
          application.destroy!
        end
      end
    end
  end
end
