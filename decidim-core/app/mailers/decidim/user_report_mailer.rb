# frozen_string_literal: true

module Decidim
  # A custom mailer to notify Decidim users
  # that they have been reported
  class UserReportMailer < ApplicationMailer
    def notify(admin, token, reason, user)
      @user = user
      @organization = user.organization
      @token = token
      @reason = reason
      @admin = admin
      mail(to: admin.email, subject: I18n.t(
        "decidim.user_report_mailer.notify.subject",
        organization_name: @organization.name,
        reason: @reason,
        token: @token
      ))
    end
  end
end
