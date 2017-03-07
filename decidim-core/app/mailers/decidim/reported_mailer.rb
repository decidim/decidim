# frozen_string_literal: true
module Decidim
  # A custom mailer for sending notifications to an admin when a report is created..
  class ReportedMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper

    def report(user, report)
      with_user(user) do
        @report = report
        @organization = user.organization
        @user = user
        subject = I18n.t("report.subject", scope: "decidim.reported_mailer")
        mail(to: user.email, subject: subject)
      end
    end

    def hide(user, report)
      with_user(user) do
        @report = report
        @organization = user.organization
        @user = user
        subject = I18n.t("hide.subject", scope: "decidim.reported_mailer")
        mail(to: user.email, subject: subject)
      end
    end
  end
end
