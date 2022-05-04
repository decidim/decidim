# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying a newsletter from the admin panel.
    class DestroyNewsletter < Decidim::Command
      # Public: Initializes the command.
      #
      # newsletter - The Newsletter to be destroyed.
      def initialize(newsletter, current_user)
        @newsletter = newsletter
        @current_user = current_user
      end

      # Public: Executes the command.
      #
      # Broadcasts :ok if it got destroyed
      def call
        return broadcast(:already_sent) if newsletter.sent?

        destroy_newsletter
        broadcast(:ok)
      end

      private

      attr_reader :newsletter, :current_user

      def destroy_newsletter
        Decidim.traceability.perform_action!(
          "delete",
          newsletter,
          current_user
        ) do
          newsletter.destroy!
        end
      end
    end
  end
end
