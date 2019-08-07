# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to close a current impersonation session.
    class CloseSessionManagedUser < Rectify::Command
      # Public: Initializes the command.
      #
      # user         - The user impersonated.
      # current_user - The current user doing the impersonation.
      def initialize(user, current_user)
        @user = user
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the impersonation is not valid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if impersonation_log.blank?

        close_session

        broadcast(:ok)
      end

      attr_reader :current_user, :user

      private

      def impersonation_log
        @impersonation_log ||= Decidim::ImpersonationLog.where(admin: current_user, user: user).active.first
      end

      def close_session
        impersonation_log.ended_at = Time.current
        impersonation_log.save!
      end
    end
  end
end
