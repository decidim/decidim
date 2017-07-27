# frozen_string_literal: true

module Decidim
  module Admin
    class ExpireImpersonationJob < ApplicationJob
      queue_as :default

      def perform(user, current_user)
        impersonation_log = Decidim::ImpersonationLog.where(admin: current_user, user: user).active.first
        return unless impersonation_log
        impersonation_log.expired_at = Time.current
        impersonation_log.save!
      end
    end
  end
end
