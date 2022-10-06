# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe AnswerProposal do
        subject { command.call }

        let(:command) { described_class.new(form, proposal) }
        let(:proposal) { create(:proposal) }
        let(:current_user) { create(:user, :admin) }
        let(:form) do
          ProposalAnswerForm.from_params(form_params).with_context(
            current_user:,
            current_component: proposal.component,
            current_organization: proposal.component.organization
          )
        end

        let(:form_params) do
          {
            internal_state: "rejected",
            answer: { en: "Foo" },
            cost: 2000,
            cost_report: { en: "Cost report" },
            execution_period: { en: "Execution period" }
          }
        end

        it "broadcasts ok" do
          expect { subject }.to broadcast(:ok)
        end

        it "publish the proposal answer" do
          expect { subject }.to change { proposal.reload.published_state? }.to(true)
        end

        it "changes the proposal state" do
          expect { subject }.to change { proposal.reload.state }.to("rejected")
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("answer", proposal, form.current_user)
            .and_call_original

          expect { subject }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "update"
        end

        it "notifies the proposal answer" do
          expect(NotifyProposalAnswer)
            .to receive(:call)
            .with(proposal, nil)

          subject
        end

        context "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end

          it "doesn't change the proposal state" do
            expect { subject }.not_to(change { proposal.reload.state })
          end
        end

        context "when applying over an already answered proposal" do
          let(:proposal) { create(:proposal, :accepted) }

          it "broadcasts ok" do
            expect { subject }.to broadcast(:ok)
          end

          it "changes the proposal state" do
            expect { subject }.to change { proposal.reload.state }.to("rejected")
          end

          it "notifies the proposal new answer" do
            expect(NotifyProposalAnswer)
              .to receive(:call)
              .with(proposal, "accepted")

            subject
          end
        end

        context "when proposal answer should not be published immediately" do
          let(:proposal) { create(:proposal, component:) }
          let(:component) { create(:proposal_component, :without_publish_answers_immediately) }

          it "broadcasts ok" do
            expect { subject }.to broadcast(:ok)
          end

          it "changes the proposal internal state" do
            expect { subject }.to change { proposal.reload.internal_state }.to("rejected")
          end

          it "doesn't publish the proposal answer" do
            expect { subject }.not_to change { proposal.reload.published_state? }.from(false)
          end

          it "doesn't notify the proposal answer" do
            expect(NotifyProposalAnswer)
              .not_to receive(:call)

            subject
          end
        end
      end
    end
  end
end
