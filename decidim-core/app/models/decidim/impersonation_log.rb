# frozen_string_literal: true

module Decidim
  # ImpersonationLogs are created whenever an admin impersonate a managed user
  class ImpersonationLog < ApplicationRecord
    SESSION_TIME_IN_MINUTES = 30

    belongs_to :admin, foreign_key: "decidim_admin_id", class_name: "Decidim::User"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    validate :same_organization

    scope :active, -> { where(ended_at: nil, expired_at: nil) }
    scope :expired, -> { where(ended_at: nil).where.not(expired_at: nil) }

    def ended?
      ended_at.present?
    end

    def expired?
      expired_at.present?
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ImpersonationLogPresenter
    end

    private

    def same_organization
      return if admin&.organization == user&.organization

      errors.add(:admin, :invalid)
    end
  end
end
