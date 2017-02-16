# -*- coding: utf-8 -*-
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalReportedMailer, type: :mailer do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, organization: organization) }
      let(:feature) { create(:proposal_feature, organization: organization) }
      let(:proposal) { create(:proposal, feature: feature) }
      let(:proposal_report) { create(:proposal_report, proposal: proposal) }

      describe "#report" do
        let(:mail) { described_class.report(user, proposal_report) }

        let(:subject) { "Una proposta ha estat reportada" }
        let(:default_subject) { "A proposal has been reported" }

        let(:body) { "ha estat reportada" }
        let(:default_body) { "has been reported" }

        include_examples "localised email"
      end
    end
  end
end
