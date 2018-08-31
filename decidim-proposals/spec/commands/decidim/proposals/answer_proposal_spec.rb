# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe AnswerProposal do
        describe "call" do
          let(:proposal) { create(:proposal) }
          let(:current_user) { create(:user, :admin) }
          let(:form) { ProposalAnswerForm.from_params(form_params).with_context(current_user: current_user) }
          let(:form_params) do
            {
              state: "rejected", answer: { en: "Foo" }
            }
          end

          let(:command) { described_class.new(form, proposal) }

          describe "when the form is not valid" do
            before do
              expect(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't update the proposal" do
              expect(proposal).not_to receive(:update!)
              command.call
            end
          end

          describe "when the form is valid" do
            before do
              expect(form).to receive(:invalid?).and_return(false)
            end

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "updates the proposal" do
              command.call

              expect(proposal.reload).to be_answered
            end

            context "when accepted" do
              before do
                form.state = "accepted"
              end

              it "updates the gamification score for their authors" do
                expect { command.call }.to change {
                  Decidim::Gamification.status_for(proposal.authors.first, :accepted_proposals).score
                }.by(1)
              end
            end

            context "when rejected" do
              before do
                form.state = "rejected"
              end

              it "doesn't update the gamification score for their authors" do
                expect { command.call }.to change {
                  Decidim::Gamification.status_for(proposal.authors.first, :accepted_proposals).score
                }.by(0)
              end
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:perform_action!)
                .with("answer", proposal, form.current_user)
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
              expect(action_log.version.event).to eq "update"
            end

            context "when the state changes" do
              it "notifies the proposal followers" do
                follower = create(:user, organization: proposal.organization)
                create(:follow, followable: proposal, user: follower)

                expect(Decidim::EventsManager)
                  .to receive(:publish)
                  .with(
                    event: "decidim.events.proposals.proposal_rejected",
                    event_class: Decidim::Proposals::RejectedProposalEvent,
                    resource: proposal,
                    recipient_ids: [follower.id]
                  )

                command.call
              end
            end
          end
        end
      end
    end
  end
end
