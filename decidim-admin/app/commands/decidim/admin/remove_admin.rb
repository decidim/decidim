# frozen_string_literal: true

module Decidim
  module Admin
    # A command to remove the admin privilege to an user.
    class RemoveAdmin < Decidim::Command
      # Public: Initializes the command.
      #
      # user - the user that will no longer be an admin
      # current_user - the user that performs the action
      def initialize(user, current_user)
        @user = user
        @current_user = current_user
      end

      def call
        return broadcast(:invalid) unless user

        Decidim.traceability.perform_action!(
          "remove_from_admin",
          user,
          current_user,
          extra: {
            invited_user_role: user_role
          }
        ) do
          user.update!(admin: false, roles: [])
        end

        broadcast(:ok)
      end

      private

      attr_reader :user, :current_user

      def user_role
        user.admin? ? :admin : user.roles.last
      end
    end
  end
end
