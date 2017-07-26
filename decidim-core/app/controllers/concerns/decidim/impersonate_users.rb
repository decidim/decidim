# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need user impersonation logic.
  module ImpersonateUsers
    extend ActiveSupport::Concern

    included do
      alias_method :real_user, :current_user

      # TODO
      def current_user
        managed_user || real_user
      end

      private

      # TODO
      def managed_user
        return if !real_user || !real_user.can?(:impersonate, :managed_users)

        impersonation = Decidim::ImpersonationLog
                        .order("start_at DESC")
                        .where(admin: real_user)
                        .first

        return if !impersonation || impersonation.expired?
        impersonation.user
      end
    end
  end
end
