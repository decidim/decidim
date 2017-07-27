# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need user impersonation logic.
  module ImpersonateUsers
    extend ActiveSupport::Concern

    included do
      alias_method :real_user, :current_user

      # Returns a manager user if the real user has an active impersonation
      def current_user
        managed_user || real_user
      end

      private

      # Returns the managed user impersonated by an admin if exists
      def managed_user
        return if !real_user || !real_user.can?(:impersonate, :managed_users)

        impersonation = Decidim::ImpersonationLog
                        .order("start_at DESC")
                        .where(admin: real_user)
                        .active
                        .first

        impersonation&.user
      end
    end
  end
end
