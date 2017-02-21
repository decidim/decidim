# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ReportProposal do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:feature) { create(:proposal_feature, organization: organization) }
        let(:proposal) { create(:proposal, feature: feature) }
        let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
        let(:user) { create(:user, :confirmed, organization: organization) }
        let(:form) { ProposalReportForm.from_params(form_params) }
        let(:form_params) do
          {
            type: "spam"
          }
        end

        let(:command) { described_class.new(form, proposal, user) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create the proposal report" do
            expect {
              command.call
            }.to_not change { ProposalReport.count }
          end
        end

        describe "when the form is valid" do
          before do
            expect(form).to receive(:invalid?).and_return(false)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a proposal report" do
            command.call
            last_report = ProposalReport.last

            expect(last_report.proposal).to eq(proposal)
            expect(last_report.user).to eq(user)
            expect(proposal.reload.report_count).to eq(1)
          end

          it "sends an email to the admin" do
            allow(ProposalReportedMailer).to receive(:report).and_call_original
            command.call
            last_report = ProposalReport.last
            expect(ProposalReportedMailer)
              .to have_received(:report)
              .with(admin, last_report)
          end

          context "and the proposal has been already reported two times" do
            before do
              expect(form).to receive(:invalid?).at_least(:once).and_return(false)
              (Decidim.max_reports_before_hiding - 1).times do
                described_class.new(form, proposal, create(:user, organization: organization)).call
              end
            end

            it "marks the proposal as hidden" do
              command.call
              expect(proposal.reload).to be_hidden
            end

            it "sends an email to the admin" do
              allow(ProposalReportedMailer).to receive(:hide).and_call_original
              command.call
              last_report = ProposalReport.last
              expect(ProposalReportedMailer)
                .to have_received(:hide)
                .with(admin, last_report)
            end
          end
        end
      end
    end
  end
end
