# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe PublishAnswers do
        subject { command.call }

        let(:command) { described_class.new(component, user, proposal_ids) }
        let(:proposal_ids) { proposals.map(&:id) }
        let(:proposals) { create_list(:proposal, 5, :accepted_not_published, component:) }
        let(:component) { create(:proposal_component) }
        let(:user) { create(:user, :admin) }

        it "broadcasts ok" do
          expect { subject }.to broadcast(:ok)
        end

        it "publish the answers" do
          expect { subject }.to change { proposals.map { |proposal| proposal.reload.published_state? }.uniq }.to([true])
        end

        it "changes the proposals published state" do
          expect { subject }.to change { proposals.map { |proposal| proposal.reload.state }.uniq }.from([nil]).to(["accepted"])
        end

        it "traces the action", versioning: true do
          proposals.each do |proposal|
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("publish_answer", proposal, user)
              .and_call_original
          end

          expect { subject }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "update"
        end

        it "notifies the answers" do
          proposals.each do |proposal|
            expect(NotifyProposalAnswer)
              .to receive(:call)
              .with(proposal, nil)
          end

          subject
        end

        context "when proposal ids belong to other component" do
          let(:proposals) { create_list(:proposal, 5, :accepted) }

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end

          it "doesn't publish the answers" do
            expect { subject }.not_to(change { proposals.map { |proposal| proposal.reload.published_state? }.uniq })
          end

          it "doesn't trace the action" do
            expect(Decidim.traceability)
              .not_to receive(:perform_action!)

            subject
          end

          it "doesn't notify the answers" do
            expect(NotifyProposalAnswer).not_to receive(:call)

            subject
          end
        end
      end
    end
  end
end
