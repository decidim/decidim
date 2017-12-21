# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when unofficializing a user.
    class UnofficializeUser < Rectify::Command
      # Public: Initializes the command.
      #
      # user - The user to be unofficialized.
      def initialize(user)
        @user = user
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

      attr_reader :user

      def unofficialize_user
        user.update!(officialized_at: nil, officialized_as: nil)
      end
    end
  end
end
