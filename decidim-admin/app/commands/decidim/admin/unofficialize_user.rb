# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when unofficializing a user.
    class UnofficializeUser < Decidim::Command
      # Public: Initializes the command.
      #
      # user - The user to be unofficialized.
      # current_user - The user performing the action
      def initialize(user, current_user)
        @user = user
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when the unofficialization suceeds.
      # - :invalid when the form is invalid.
      #
      # Returns nothing.
      def call
        unofficialize_user

        broadcast(:ok)
      end

      private

      attr_reader :user, :current_user

      def unofficialize_user
        Decidim.traceability.perform_action!(
          "unofficialize",
          user,
          current_user,
          extra: {
            officialized_user_badge: nil,
            officialized_user_badge_previous: user.officialized_as,
            officialized_user_at: nil,
            officialized_user_at_previous: user.officialized_at
          }
        ) do
          user.update!(officialized_at: nil, officialized_as: nil)
        end
      end
    end
  end
end
