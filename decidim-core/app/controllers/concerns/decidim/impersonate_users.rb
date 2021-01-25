# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need user impersonation logic.
  module ImpersonateUsers
    extend ActiveSupport::Concern

    included do
      before_action :check_impersonation_log_expired # Exclude xhr (ajax) requests --- RUN THIS ONLY IF NORMAL REQUEST WHERE WE RENDER HTML

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
        return if impersonation_log.blank?

        @managed_user ||= begin
          impersonation_log.ensure_not_expired!
          impersonation_log.user
        end
      end

      # Check if the active impersonation session has expired or not.
      def check_impersonation_log_expired
        # Rails.logger.info("can_impersonate_users?: #{can_impersonate_users?}")
        # Rails.logger.info("expired_log: #{expired_log}")
        # Rails.logger.info("request.xhr?: #{request.xhr?}")
        # Rails.logger.info("orginal_url: #{request.original_url}")

        # Do not redirect on ajax requests
        # raise request.xhr?.inspect
        return if request && request.xhr?
        # TODO: Explain why we don't run it on non-HTML responses
        return if request && request.negotiate_mime([Mime[:html]]).blank?
        return unless can_impersonate_users?
        return unless expired_log

        # respond_to do |format|
        #   format.html do
        #   end
        # end
        expired_log.update!(ended_at: Time.current)
        flash[:alert] = I18n.t("managed_users.expired_session", scope: "decidim")
        Rails.logger.info("REDIRECT TO: #{decidim_admin.impersonatable_users_path}")
        # close_session
        redirect_to decidim_admin.impersonatable_users_path
      end

      def can_impersonate_users?
        # real_user && allowed_to?(:impersonate, :managed_user, { skip_ensure_not_expired: true }, [Decidim::Admin::Permissions], real_user)
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
