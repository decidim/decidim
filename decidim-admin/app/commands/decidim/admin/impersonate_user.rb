# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to impersonate a managed user.
    class ImpersonateUser < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - The form with the authorization info
      # user         - The user to impersonate
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the impersonation is not valid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        transaction do
          user.save! unless user.persisted?

          create_authorization

          create_impersonation_log
        end

        enqueue_expire_job

        broadcast(:ok)
      end

      private

      attr_reader :form

      def user
        form.user
      end

      def create_authorization
        Authorization.create_or_update_from(form.authorization)
      end

      def create_impersonation_log
        Decidim::ImpersonationLog.create!(
          admin: form.current_user,
          user: user,
          reason: form.reason,
          started_at: Time.current
        )
      end

      def enqueue_expire_job
        Decidim::Admin::ExpireImpersonationJob
          .set(wait: Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes)
          .perform_later(user, form.current_user)
      end
    end
  end
end
