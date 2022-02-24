# frozen_string_literal: true

module Decidim
  # A custom mailer to notify Decidim users
  # that they have been reported
  class UserReportMailer < ApplicationMailer
    def notify(admin, report)
      @report = report
      @admin = admin
      @organization = report.moderation.user.organization
      with_user(admin) do
        mail(to: admin.email, subject: I18n.t(
          "decidim.user_report_mailer.notify.subject",
          organization_name: report.moderation.user.organization.name,
          reason: @report.reason
        ))
      end
    end
  end
end
