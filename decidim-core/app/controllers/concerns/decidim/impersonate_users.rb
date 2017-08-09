# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need user impersonation logic.
  module ImpersonateUsers
    extend ActiveSupport::Concern

    included do
      before_action :check_impersonation_log_expired

      helper_method :impersonation_session_ends_at, :impersonation_session_remaining_duration_in_minutes

      alias_method :real_user, :current_user

      # Returns a manager user if the real user has an active impersonation
      def current_user
        managed_user || real_user
      end

      def impersonation_session_ends_at
        @impersonation_session_ends_at ||= impersonation_log.started_at + Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes
      end

      def impersonation_session_remaining_duration_in_minutes
        ((impersonation_session_ends_at - Time.current) / 60).round
      end

      private

      # Returns the managed user impersonated by an admin if exists
      def managed_user
        return unless can_impersonate_users?
        impersonation_log&.user
      end

      # Check if the active impersonation session has expired or not.
      def check_impersonation_log_expired
        return unless can_impersonate_users? && impersonation_log

        if impersonation_log.expired?
          impersonation_log.ended_at = Time.current
          impersonation_log.save!
          flash[:alert] = I18n.t("managed_users.expired_session", scope: "decidim")
          redirect_to decidim_admin.managed_users_path
        end
      end

      # Gets the ability instance for the real user logged in.
      def real_ability
        @real_ability ||= current_ability_klass.new(real_user, ability_context)
      end

      def can_impersonate_users?
        real_user && real_ability.can?(:impersonate, :managed_users)
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
