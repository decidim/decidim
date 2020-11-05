# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need user impersonation logic.
  module ImpersonateUsers
    extend ActiveSupport::Concern

    included do
      before_action :check_impersonation_log_expired

      helper_method :impersonation_session_ends_at, :impersonation_session_remaining_duration_in_minutes, :current_user_impersonated?

      # Get the current user from warden because at the load time the
      # `current_user` method may not yet be available. It is added mounting of
      # the routes.
      # See:
      # https://github.com/plataformatec/devise/blob/14863ba4c92cd9781a961be0486f0ea7dfe84144/lib/devise/controllers/helpers.rb#L125-L127
      def real_user
        @real_user ||= warden.authenticate(scope: :user)
      end

      # Returns a manager user if the real user has an active impersonation
      def current_user
        @current_user ||= managed_user || real_user
      end

      # Clear the `@real_user` instance variable because otherwise that would be
      # the return value for any `current_user` calls after the user has already
      # signed out.
      # See:
      # https://github.com/heartcombo/devise/blob/97a6fd289548226d7b0638848259566605418529/lib/devise/controllers/sign_in_out.rb#L80
      def sign_out(resource_or_scope = nil)
        result = super

        @real_user = nil

        result
      end

      def impersonation_session_ends_at
        @impersonation_session_ends_at ||= impersonation_log.started_at + Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes
      end

      def impersonation_session_remaining_duration_in_minutes
        ((impersonation_session_ends_at - Time.current) / 60).round
      end

      private

      def current_user_impersonated?
        current_user && impersonation_log.present?
      end

      # Returns the managed user impersonated by an admin if exists
      def managed_user
        return unless can_impersonate_users?

        impersonation_log&.user
      end

      # Check if the active impersonation session has expired or not.
      def check_impersonation_log_expired
        return unless can_impersonate_users? && expired_log

        expired_log.ended_at = Time.current
        expired_log.save!
        flash[:alert] = I18n.t("managed_users.expired_session", scope: "decidim")
        redirect_to decidim_admin.impersonatable_users_path
      end

      def can_impersonate_users?
        real_user && allowed_to?(:impersonate, :managed_user, {}, [Decidim::Admin::Permissions], real_user)
      end

      def expired_log
        @expired_log ||= Decidim::ImpersonationLog
                         .where(admin: real_user)
                         .expired
                         .first
      end

      def impersonation_log
        @impersonation_log ||= Decidim::ImpersonationLog
                               .where(admin: real_user)
                               .active
                               .first
      end
    end
  end
end
