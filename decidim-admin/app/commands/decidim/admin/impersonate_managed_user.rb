# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to impersonate a managed user.
    class ImpersonateManagedUser < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - The form with the authorization info
      # user         - The user to impersonate
      # current_user - The current user doing the impersonation.
      def initialize(form, user, current_user)
        @form = form
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
        return broadcast(:invalid) if !user.managed? || !authorization_valid?

        create_impersonation_log
        enque_expire_job

        broadcast(:ok)
      end

      private

      attr_reader :current_user, :user, :form

      def authorization_valid?
        return false unless form.valid?
        Decidim::Authorization.where(
          user: user,
          name: form.authorization.handler_name,
          unique_id: form.authorization.unique_id
        ).any?
      end

      def create_impersonation_log
        Decidim::ImpersonationLog.create!(
          admin: current_user,
          user: user,
          started_at: Time.current
        )
      end

      def enque_expire_job
        Decidim::Admin::ExpireImpersonationJob
          .set(wait: Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes)
          .perform_later(user, current_user)
      end
    end
  end
end
