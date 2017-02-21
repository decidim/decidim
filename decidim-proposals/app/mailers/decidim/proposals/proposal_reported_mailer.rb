# frozen_string_literal: true
module Decidim
  module Proposals
    # A custom mailer for sending notifications to an admin when a proposal is reported.
    class ProposalReportedMailer < Decidim::ApplicationMailer
      helper Decidim::ResourceHelper

      def report(user, proposal_report)
        with_user(user) do
          @proposal_report = proposal_report
          @organization = user.organization
          @user = user
          subject = I18n.t("report.subject", scope: "decidim.proposals.proposal_reported_mailer")
          mail(to: user.email, subject: subject)
        end
      end

      def hide(user, proposal_report)
        with_user(user) do
          @proposal_report = proposal_report
          @organization = user.organization
          @user = user
          subject = I18n.t("hide.subject", scope: "decidim.proposals.proposal_reported_mailer")
          mail(to: user.email, subject: subject)
        end
      end
    end
  end
end
