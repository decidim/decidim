# frozen_string_literal: true

module Decidim
  # A mailer to notify users about their account status
  class ParticipantsAccountMailer < Decidim::ApplicationMailer
    # Notify user about inactivity and potential account removal
    def inactivity_notification(user, days)
      return unless user

      @user = user
      @organization = user.organization
      @days_before_deletion = days

      subject = I18n.t(
        "decidim.participants_account_mailer.inactivity_notification.subject",
        organization_name: organization_name(@organization)
      )

      mail(to: user.email, subject:)
    rescue StandardError => e
      Rails.logger.error "Failed to send inactivity notification to #{user.email}: #{e.message}"
    end

    # Notify user about account removal due to inactivity
    def removal_notification(user)
      return unless user

      @user = user
      @organization = user.organization

      subject = I18n.t(
        "decidim.participants_account_mailer.removal_notification.subject",
        organization_name: organization_name(@organization)
      )

      mail(to: user.email, subject:)
    rescue StandardError => e
      Rails.logger.error "Failed to send removal notification to #{user.email}: #{e.message}"
    end
  end
end
